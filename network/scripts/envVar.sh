#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
. scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
export PEER0_MNGORG_CA=${PWD}/organizations/peerOrganizations/mngorg.example.com/tlsca/tlsca.mngorg.example.com-cert.pem
# export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/tls-localhost-9054-ca-orderer.pem
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG = "mngorg" ]; then
    export CORE_PEER_LOCALMSPID="MngOrgMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MNGORG_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/mngorg.example.com/users/Admin@mngorg.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

setGlobals1() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG = "mngorg" ]; then
    export CORE_PEER_LOCALMSPID="MngOrgMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MNGORG_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/mngorg.example.com/users/Admin@mngorg.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}


setGlobals2() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG = "mngorg" ]; then
    export CORE_PEER_LOCALMSPID="MngOrgMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MNGORG_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/mngorg.example.com/users/Admin@mngorg.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}


setGlobals3() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG = "mngorg" ]; then
    export CORE_PEER_LOCALMSPID="MngOrgMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MNGORG_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/mngorg.example.com/users/Admin@mngorg.example.com/msp
    export CORE_PEER_ADDRESS=localhost:13051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}
# Set environment variables for use in the CLI container

setGlobalsCLI() {
  setGlobals $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ $USING_ORG = "mngorg" ]; then
    export CORE_PEER_ADDRESS=peer0.mngorg.example.com:7051
  else
    errorln "ORG Unknown"
  fi
}

setGlobalsCLI1() {
  setGlobals1 $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ $USING_ORG = "mngorg" ]; then
    export CORE_PEER_ADDRESS=peer1.mngorg.example.com:9051
  else
    errorln "ORG Unknown"
  fi
}


setGlobalsCLI2() {
  setGlobals2 $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ $USING_ORG = "mngorg" ]; then
    export CORE_PEER_ADDRESS=peer2.mngorg.example.com:11051
  else
    errorln "ORG Unknown"
  fi
}


setGlobalsCLI3() {
  setGlobals3 $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ $USING_ORG = "mngorg" ]; then
    export CORE_PEER_ADDRESS=peer3.mngorg.example.com:13051
  else
    errorln "ORG Unknown"
  fi
}
# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""
  infoln "DEBUGGGG"
  infoln "$#"
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	PEERS="$PEER"
    else
	PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    CA=PEER0_${1^^}_CA
    
    # DEBUGGING
    infoln "DEBUG KE-2"
    infoln "$1"
    infoln "${CA}"

    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}

parsePeerConnectionParameters1() {
  PEER_CONN_PARMS=()
  PEERS=""
  infoln "DEBUGGGG"
  infoln "$#"
  while [ "$#" -gt 0 ]; do
    setGlobals1 $1
    PEER="peer1.$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	PEERS="$PEER"
    else
	PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    CA=PEER0_${1^^}_CA
    
    # DEBUGGING
    infoln "DEBUG KE-2"
    infoln "$1"
    infoln "${CA}"

    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}


parsePeerConnectionParameters2() {
  PEER_CONN_PARMS=()
  PEERS=""
  infoln "DEBUGGGG"
  infoln "$#"
  while [ "$#" -gt 0 ]; do
    setGlobals2 $1
    PEER="peer2.$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	PEERS="$PEER"
    else
	PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    CA=PEER0_${1^^}_CA
    
    # DEBUGGING
    infoln "DEBUG KE-2"
    infoln "$1"
    infoln "${CA}"

    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}


parsePeerConnectionParameters3() {
  PEER_CONN_PARMS=()
  PEERS=""
  infoln "DEBUGGGG"
  infoln "$#"
  while [ "$#" -gt 0 ]; do
    setGlobals3 $1
    PEER="peer3.$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	PEERS="$PEER"
    else
	PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    CA=PEER0_${1^^}_CA
    
    # DEBUGGING
    infoln "DEBUG KE-2"
    infoln "$1"
    infoln "${CA}"

    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
