"""Small TEMPEST client for the downloadable rocket workspace.

HTTP operations use the Python standard library. --watch additionally needs
pyzmq: python -m pip install pyzmq. Each HTTP operation has a fresh connection;
an uncertain command is never retried automatically.
"""
import argparse
import json
import os
import time
import urllib.error
import urllib.request


class Session:
    def __init__(self, host="127.0.0.1", port=7400, password=None, viewer=False):
        self.host, self.port = host, port
        self.client_id = self.token = ""
        payload = {"role": "viewer"} if viewer else {
            "serverPassword": password if password is not None else os.environ["DARTWIC_PASSWORD"],
            "username": "rocket-example",
        }
        registration = self.operation("register_client", payload)
        self.client_id, self.token = registration["clientId"], registration["sessionToken"]

    def operation(self, name, payload=None):
        body = json.dumps({"name": name, "payload": payload or {},
            "clientId": self.client_id, "sessionToken": self.token,
            "timestamp": time.time_ns() // 1_000_000}).encode()
        request = urllib.request.Request(f"http://{self.host}:{self.port+2}/tempest/operation",
            body, {"Content-Type": "application/json"})
        try:
            response = urllib.request.urlopen(request, timeout=15)
        except urllib.error.HTTPError as error:
            response = error
        with response:
            result = json.load(response)
        if result.get("error"):
            raise RuntimeError(f"{name}: {result['payload']}")
        return result["payload"]

    def channels(self, names):
        return self.operation("rapid/get-channels-data", {"channel_names": names})

    def write(self, channel, value):
        return self.operation("rapid/upsert-channel-field", {
            "channel_name": channel, "field": "value", "value": value,
        })

    def watch(self, channel, seconds=10):
        import zmq
        context = zmq.Context()
        socket = context.socket(zmq.SUB)
        socket.setsockopt(zmq.LINGER, 0)
        socket.setsockopt_string(zmq.SUBSCRIBE, "rapid/channels/snapshot")
        socket.connect(f"tcp://{self.host}:{self.port+1}")
        self.operation("dartwic/add-channel-to-telemetry", {"channel_name": channel})
        deadline, heartbeat = time.monotonic()+seconds, time.monotonic()+5
        try:
            while time.monotonic() < deadline:
                if time.monotonic() >= heartbeat:
                    self.operation("heartbeat")
                    heartbeat = time.monotonic()+5
                if socket.poll(100, zmq.POLLIN):
                    topic, body = socket.recv_multipart()
                    data = json.loads(body).get("payload", {})
                    if data.get("client_id") == self.client_id and channel in data.get("channels", {}):
                        record = data["channels"][channel]
                        fields = record.get("channel_data", {})
                        print(json.dumps({"channel":channel, "available":record.get("available"),
                            "value":fields.get("value"), "units":fields.get("units"), "timestamp":fields.get("timestamp")}))
        finally:
            self.operation("dartwic/remove-channel-from-telemetry", {"channel_name": channel})
            socket.close()
            context.term()

    def close(self):
        self.operation("unregister_client")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=7400)
    parser.add_argument("--viewer", action="store_true")
    parser.add_argument("--watch", metavar="CHANNEL")
    parser.add_argument("--seconds", type=float, default=10)
    parser.add_argument("--set", nargs=2, metavar=("CHANNEL", "JSON_VALUE"))
    parser.add_argument("--operation", nargs=2, metavar=("NAME", "JSON_PAYLOAD"))
    args = parser.parse_args()
    client = Session(args.host, args.port, viewer=args.viewer)
    try:
        if args.set:
            print(client.write(args.set[0], json.loads(args.set[1])))
        elif args.operation:
            print(json.dumps(client.operation(args.operation[0], json.loads(args.operation[1])), indent=2))
        elif args.watch:
            client.watch(args.watch, args.seconds)
        else:
            print(json.dumps(client.channels(["rocket_sim_pressure", "rocket_sim_temperature_voted", "rocket_sim_sensor_valid"]), indent=2))
    finally:
        client.close()


if __name__ == "__main__":
    main()
