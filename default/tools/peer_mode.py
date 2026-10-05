"""Select the ground connection; stop the other flight process first."""
import argparse,json
from pathlib import Path
from tempest_client import Session
parser=argparse.ArgumentParser();parser.add_argument('mode',choices=['native','custom']);parser.add_argument('--port',type=int,default=7400);args=parser.parse_args()
s=Session(port=args.port)
try:
    s.operation('tempest/peers/disconnect',{'node_name':'FLIGHT_COMPUTER','forget':True})
    if args.mode=='custom':
        settings=json.loads((Path(__file__).resolve().parent/'peer-connection.json').read_text())
        print(s.operation('tempest/peers/connect',settings))
    else: print('Custom connection removed. Start the native flight peer now.')
finally: s.close()
