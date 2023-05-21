#! /usr/bin/python3

import subprocess
import shlex


subprocess.run(shlex.split('./network.sh down'))

# creating the channel

subprocess.run(shlex.split('./network.sh createChannel -ca -verbose'))

# invoking chaincode in all the nodes

subprocess.run(shlex.split('./network.sh deployCC -ccn mngcc -ccp ../Chaincode-go -ccl go  -verbose'))