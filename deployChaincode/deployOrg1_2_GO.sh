#!/usr/bin/env bash

chaincodeInfo() {
 export CHANNEL_NAME="mychannel"
  export CC_RUNTIME_LANGUAGE="golang"
  export CC_VERSION="1"
  export CC_SRC_PATH=../chaincodes/ipfs
  export CC_NAME="ipfschaincode"
  export CC_SEQUENCE="1"
}
export PATH=$PATH:/usr/local/go/bin

preSetupGO() {
  echo Vendoring Go dependencies ...
  export PATH=$PATH:/usr/local/go/bin
  pushd ../chaincodes/golang
  GO111MODULE=on go mod vendor
  popd
  echo Finished vendoring Go dependencies
}

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../orderer/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/../org1/crypto-config-ca/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/../org2/crypto-config-ca/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../config

setGlobalsForPeer0Org1() {
  export CORE_PEER_LOCALMSPID="Org1MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/../org1/crypto-config-ca/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
  export CORE_PEER_ADDRESS=localhost:7051
}

packageChaincode() {

  rm -rf ${CC_NAME}.tar.gz

  peer lifecycle chaincode package ${CC_NAME}.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label ${CC_NAME}_${CC_VERSION}

}

getblock() {
  echo getting block
  peer channel getinfo -c mychannel -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA
}

checkCommitReadyness() {
  echo checking comminting
  peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name ${CC_NAME} --sequence ${CC_SEQUENCE} --version ${CC_VERSION} --init-required --output json

}
commitChaincodeDefination() {
  echo comminting
  peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA --sequence ${CC_SEQUENCE} --version ${CC_VERSION} --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA --sequence ${CC_SEQUENCE} --version ${CC_VERSION} --init-required

}

queryCommitted() {
  echo querying commiting
  peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME} --output json

}
chaincodeInvokeInit() {

  peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME -n ${CC_NAME} --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA --isInit -c '{"function": "initLedger","Args":[]}'

}

insertTransaction() {

  peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA -c '{"function": "createCar", "Args":["CAR101","Honda","City","White", "CM"]}'

  sleep 2
}
readTransaction() {
  echo "Reading a transaction"

  # Query all cars

  peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryAllCars"]}'

  # Query Car by Id
  peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "queryCar","Args":["CAR101"]}'
}

lifecycleCommands() {
  getblock
  checkCommitReadyness
  sleep 2
  commitChaincodeDefination
  sleep 2
  
}
getInstallChaincodes() {

  peer lifecycle chaincode queryinstalled

}
preSetupGO
chaincodeInfo
setGlobalsForPeer0Org1
lifecycleCommands



 
