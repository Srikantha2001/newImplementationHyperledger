#!/usr/bin/env bash

#
# SPDX-License-Identifier: Apache-2.0
#

${AS_LOCAL_HOST:=true}

: "${TEST_NETWORK_HOME:=..}"
: "${CONNECTION_PROFILE_FILE_MNGORG:=${TEST_NETWORK_HOME}/network/organizations/peerOrganizations/mngorg.example.com/connection-mngorg.json}"
: "${CERTIFICATE_FILE_MNGORG:=${TEST_NETWORK_HOME}/network/organizations/peerOrganizations/mngorg.example.com/users/User1@mngorg.example.com/msp/signcerts/cert.pem}"
: "${PRIVATE_KEY_FILE_MNGORG:=${TEST_NETWORK_HOME}/network/organizations/peerOrganizations/mngorg.example.com/users/User1@mngorg.example.com/msp/keystore/*_sk}"

cat << ENV_END > .env
# Generated .env file
# See src/config.ts for details of all the available configuration variables

LOG_LEVEL=debug
PORT=3000
HLF_CERTIFICATE_MNGORG="$(cat ${CERTIFICATE_FILE_MNGORG} | sed -e 's/$/\\n/' | tr -d '\r\n')"
HLF_PRIVATE_KEY_MNGORG="$(cat ${PRIVATE_KEY_FILE_MNGORG} | sed -e 's/$/\\n/' | tr -d '\r\n')"
REDIS_PORT=6379

EMAIL_MNGORG="mngorg-admin@example.com"
PASSWORD_MNGORG="mngorgadmin123"
MNGORG_APIKEY=$(uuidgen)


NODE_ENV="development"
ENV_END
 
if [ "${AS_LOCAL_HOST}" = "true" ]; then

cat << LOCAL_HOST_END >> .env
AS_LOCAL_HOST=true

HLF_CONNECTION_PROFILE_MNGORG=$(cat ${CONNECTION_PROFILE_FILE_MNGORG} | jq -c .)

REDIS_HOST=localhost

LOCAL_HOST_END

elif [ "${AS_LOCAL_HOST}" = "false" ]; then

cat << WITH_HOSTNAME_END >> .env
AS_LOCAL_HOST=false

HLF_CONNECTION_PROFILE_MNGORG=$(cat ${CONNECTION_PROFILE_FILE_MNGORG} | jq -c '.peers["peer0.mngorg.example.com"].url = "grpcs://peer0.mngorg.example.com:7051" | .peers["peer1.mngorg.example.com"].url = "grpcs://peer1.mngorg.example.com:9051" |.peers["peer2.mngorg.example.com"].url = "grpcs://peer2.mngorg.example.com:11051" |.peers["peer3.mngorg.example.com"].url = "grpcs://peer3.mngorg.example.com:13051" | .certificateAuthorities["ca.mngorg.example.com"].url = "https://ca.mngorg.example.com:7054" | .organizations["mngorg"].peers += ["peer1.mngorg.example.com","peer2.mngorg.example.com","peer3.mngorg.example.com"] ') 

REDIS_HOST=redis

WITH_HOSTNAME_END

fi
