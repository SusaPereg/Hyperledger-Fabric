


export FABRIC_CFG_PATH=$PWD
configtxgen -printOrg Org3MSP > $PWD/crypto-config-ca/peerOrganizations/org3.example.com/org3.json

# DEBERIA AHORA DE HACER EL DOCKER IP, PERO YO YA LO TENGO LEVANTADO 