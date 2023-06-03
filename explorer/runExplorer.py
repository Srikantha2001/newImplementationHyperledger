import os
import json
import subprocess
import shlex

folder_path = "../network/organizations/peerOrganizations/mngorg.example.com/users/Admin@mngorg.example.com/msp/keystore/"
files = os.listdir(folder_path)

with open('./connection-profile/test-network.json') as config_file:
    config = json.load(config_file)

new_private_key_path = "/tmp/crypto/peerOrganizations/mngorg.example.com/users/Admin@mngorg.example.com/msp/keystore/"+files[0]
config["organizations"]["MngOrg"]["adminPrivateKey"]["path"] = new_private_key_path

with open('./connection-profile/test-network.json', 'w') as config_file:
    json.dump(config, config_file, indent=2)

subprocess.run(shlex.split('docker-compose down -v'))

subprocess.run(shlex.split('docker-compose up -d'))
