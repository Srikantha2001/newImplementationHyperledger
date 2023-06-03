import subprocess
import shlex

subprocess.run(shlex.split('npm run generateEnv'))
subprocess.run(shlex.split('docker build -t rest-api .'))
subprocess.run(shlex.split('docker-compose down -v'))
subprocess.run(shlex.split('docker-compose up -d'))