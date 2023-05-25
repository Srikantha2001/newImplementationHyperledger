#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0




# default to using mngorg
ORG=${1:-mngorg}

# Exit on first error, print all commands.
set -e
set -o pipefail

# Where am I?
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

ORDERER_CA=${DIR}/network/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
PEER0_MNGORG_CA=${DIR}/network/organizations/peerOrganizations/mngorg.example.com/tlsca/tlsca.mngorg.example.com-cert.pem


if [[ ${ORG,,} == "mngorg" ]; then

   CORE_PEER_LOCALMSPID=MngOrgMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/network/organizations/peerOrganizations/mngorg.example.com/users/Admin@mngorg.example.com/msp
   CORE_PEER_ADDRESS=localhost:7051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/network/organizations/peerOrganizations/mngorg.example.com/tlsca/tlsca.mngorg.example.com-cert.pem

else
   echo "Unknown \"$ORG\", please choose mngorg/Digibank or MngOrg2/Magnetocorp"
   echo
   exit 1
fi

# output the variables that need to be set
echo "CORE_PEER_TLS_ENABLED=true"
echo "ORDERER_CA=${ORDERER_CA}"
echo "PEER0_MNGORG_CA=${PEER0_MNGORG_CA}"

echo "CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH}"
echo "CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS}"
echo "CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE}"

echo "CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID}"
