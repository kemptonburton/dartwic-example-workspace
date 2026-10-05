"""Exercise the simulated device, automation, and recording. Leaves idle and faults clear.
Run only against a disposable simulated workspace: this deliberately commands
the sequence and fault controls. Set DARTWIC_PASSWORD, then python default/tools/verify_demo.py.
"""
import argparse
import json
import time
from tempest_client import Session


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--port', type=int, default=7400)
    args = parser.parse_args()
    client = Session(port=args.port)
    faults = ['overtemperature', 'sensor_bias', 'missing_sensor', 'disconnect']
    names = ['sample_counter', 'sensor_valid', 'connected', 'phase', 'pressure',
             'temperature_voted', 'temperature_spread', 'abort_active', 'sample_age_s',
             'run_fill', 'supply_fill', 'fuel_request', 'igniter_applied', 'fuel_position',
             'fuel_open_coil', 'fuel_close_coil', 'fuel_open_applied', 'fuel_close_applied']
    channels = ['rocket_sim_'+name for name in names]
    frame = None
    passed = []

    def values():
        data = client.channels(channels)['channels']
        return {name: data['rocket_sim_'+name]['channel_data']['value'] for name in names}

    def wait(label, predicate, seconds=10):
        end = time.monotonic()+seconds
        last = {}
        while time.monotonic() < end:
            last = values()
            assert not (last['fuel_open_coil'] and last['fuel_close_coil']), 'Opposing coil requests'
            assert not (last['fuel_open_applied'] and last['fuel_close_applied']), 'Opposing applied coils'
            if predicate(last):
                passed.append(label)
                print('PASS '+label, flush=True)
                return last
            time.sleep(.1)
        raise AssertionError(f'{label}: timed out; {last}')

    def write(name, value):
        client.write('rocket_test_running' if name == 'timeline_run' else 'rocket_sim_'+name, value)

    try:
        write('timeline_run', 0)
        for fault in faults:
            write('fault_'+fault, 0)
        wait('idle and valid', lambda v: v['phase']==0 and v['sensor_valid']==1 and v['abort_active']==0)
        first = values()['sample_counter']
        wait('read task advances', lambda v: v['sample_counter']>first+5)
        frame = client.operation('rapid/dataframes/start', {'name':'Rocket acceptance', 'channels':channels, 'events':'all', 'logs':'all'})
        write('fault_overtemperature', 1)
        time.sleep(.4)
        assert values()['abort_active']==0, 'High-temp switch must wait for ignition'
        write('timeline_run', 1)
        wait('high-temp switch aborts at ignition', lambda v: v['phase']==2 and v['abort_active']==1 and v['igniter_applied']==0, 20)
        assert values()['run_fill']>=59.5 and values()['supply_fill']<100, 'Supply-to-run transfer missing'
        write('fault_overtemperature', 0)
        wait('fill and ignition reach firing', lambda v: v['phase']==3 and v['igniter_applied']==1, 20)
        wait('pressure and temperature respond', lambda v: v['pressure']>40 and v['temperature_voted']>900)
        wait('bounded pulse returns off with open feedback', lambda v: v['fuel_open_coil']==0 and v['fuel_close_coil']==0 and v['fuel_position']>.95)
        write('fault_sensor_bias', 1)
        wait('median rejects one biased sensor', lambda v: v['temperature_spread']>300 and v['temperature_voted']<1500 and v['abort_active']==0)
        write('fault_sensor_bias', 0)
        write('fault_overtemperature', 1)
        wait('active abort shuts down', lambda v: v['abort_active']==1 and v['fuel_request']==0 and v['igniter_applied']==0)
        events = client.operation('argus/query-events', {'text':'Mock rocket automatic abort','limit':20})['events']
        event_id = next(event['event_id'] for event in events if event.get('correlation_key')=='dcode_declared_event|rocket_engine_abort')
        for status in ['acknowledged', 'silenced']:
            client.operation('argus/update-event-status', {'event_id':event_id,'status':status})
            wait(status+' preserves active abort', lambda v: v['abort_active']==1 and v['fuel_request']==0 and v['igniter_applied']==0)
        write('fault_overtemperature', 0)
        wait('clear releases override and resumes', lambda v: v['abort_active']==0 and v['fuel_request']==1 and v['igniter_applied']==1)
        write('fault_missing_sensor', 1)
        wait('missing samples marked invalid and stale', lambda v: v['sensor_valid']==0 and v['sample_age_s']>.3 and v['abort_active']==1)
        write('fault_missing_sensor', 0)
        wait('missing recovery resumes', lambda v: v['sensor_valid']==1 and v['abort_active']==0 and v['igniter_applied']==1)
        write('fault_disconnect', 1)
        wait('disconnect disables applied outputs', lambda v: v['connected']==0 and v['igniter_applied']==0 and v['fuel_open_applied']==0 and v['fuel_close_applied']==0)
        write('timeline_run', 0)
        write('fault_disconnect', 0)
        wait('reconnect returns idle', lambda v: v['connected']==1 and v['sensor_valid']==1 and v['phase']==0 and v['abort_active']==0)
        logs = client.operation('argus/query-logs', {'stream':'example_device_plugin/Rocket device','limit':100})['records']
        assert logs, 'Device logs missing'
        passed.append('device transition logs retained')
        print(json.dumps({'passed':passed, 'dataframe':frame}, indent=2))
    finally:
        write('timeline_run', 0)
        for fault in faults:
            write('fault_'+fault, 0)
        if frame:
            client.operation('rapid/dataframes/stop', {'name':frame['name']})
        client.close()


if __name__=='__main__':
    main()
