import json
import subprocess
import os

path = os.path.join( os.path.expanduser('~'), ".philconfig/install_data.json")
content = open( path, 'r').read()

jason = json.loads(content)
dnf = jason["dnf"]

dnf_cmd = ['sudo', 'dnf', '-y', 'install'] # + [pack for pack in [ for grp in dnf]]

for grp in dnf:
    subprocess.call(dnf_cmd + dnf[grp])
