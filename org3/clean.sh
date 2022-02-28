#!/usr/bin/env bash

#if your using centos then enable below command
sudo setenforce 0


removeOrg3CA() {

  echo "Removing Org3 CA"
  docker-compose -f ./org3/ca-org3.yaml down -v

}


removeOrg3() {

  echo "Removing Org3 Peers"
  docker-compose -f ./org3/docker-compose-peer.yaml down -v
}



removeOrg3CA
removeOrg3

echo "Removing crypto CA material"
rm -rf ./org3/fabric-ca
rm -rf ./org3/crypto-config-ca
rm -rf ./org2/crypto-config-ca
rm -rf ./org1/Org1MSPanchors.tx
rm -rf ./org2/Org2MSPanchors.tx
rm -rf ./orderer/genesis.block
rm -rf ./orderer/mychannel.tx
rm -rf ./org1/mychannel.tx
rm -rf ./org1/mychannel.block
rm -rf ./org2/mychannel.tx
rm -rf ./org2/mychannel.block
rm -rf ./explorer/dockerConfig/crypto-config
rm -rf ./deployChaincode/*.tar.gz
rm -rf ./deployChaincode/node_modules
rm -rf ./deployChaincode/log.txt
rm -rf ./deployChaincode/npm-debug.log
