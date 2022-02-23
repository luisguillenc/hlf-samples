#!/bin/bash

source .env

CHANNEL_NAME="test-channel"
CC_NAME="basic"
CC_VERSION="1.0"
CC_LABEL="${CC_NAME}_${CC_VERSION}"
CC_SEQUENCE=1

set -e

mkdir -p artifacts
cp $UTILSDIR/getChaincodeID.sh artifacts/

PACKAGE_ID=`docker exec ${COMPOSE_PROJECT_NAME}_cli-org1 ./getChaincodeID.sh $CC_LABEL`
echo "approving chaincode in org1.example.com package_id: $PACKAGE_ID"
docker exec ${COMPOSE_PROJECT_NAME}_cli-org1 \
	peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME \
		--name $CC_NAME --version $CC_VERSION --package-id $PACKAGE_ID --sequence $CC_SEQUENCE \
		-o orderer.example.com:7050 --tls --cafile tls/tlsca.example.com-cert.pem

PACKAGE_ID=`docker exec ${COMPOSE_PROJECT_NAME}_cli-org2 ./getChaincodeID.sh $CC_LABEL`
echo "approving chaincode in org2.example.com package_id: $PACKAGE_ID"
docker exec ${COMPOSE_PROJECT_NAME}_cli-org2 \
	peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME \
		--name $CC_NAME --version $CC_VERSION --package-id $PACKAGE_ID --sequence $CC_SEQUENCE \
		-o orderer.example.com:7050 --tls --cafile tls/tlsca.example.com-cert.pem

## we can check approved...
#peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json

echo "commiting chaincode"
docker exec ${COMPOSE_PROJECT_NAME}_cli-org1 \
	peer lifecycle chaincode commit --channelID $CHANNEL_NAME \
		--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /etc/hyperledger/fabric/tls/tlsca.org1.example.com-cert.pem \
		--peerAddresses peer0.org2.example.com:7051 --tlsRootCertFiles /etc/hyperledger/fabric/tls/tlsca.org2.example.com-cert.pem \
		--name $CC_NAME --version $CC_VERSION --sequence $CC_SEQUENCE \
		-o orderer.example.com:7050 --tls --cafile tls/tlsca.example.com-cert.pem


## we can check commited...
#peer lifecycle chaincode querycommitted --channelID mychannel --name basic 
