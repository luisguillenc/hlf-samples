#!/bin/bash

source .env

CHANNEL_NAME="test-channel"
CC_NAME="basic"
DELAY=2

set -e

echo "invoking chaincode: $CC_NAME function: InitLedger"
docker exec ${COMPOSE_PROJECT_NAME}_cli-org1 \
	peer chaincode invoke --channelID $CHANNEL_NAME --name $CC_NAME \
		--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /etc/hyperledger/fabric/tls/tlsca.org1.example.com-cert.pem \
		--peerAddresses peer0.org2.example.com:7051 --tlsRootCertFiles /etc/hyperledger/fabric/tls/tlsca.org2.example.com-cert.pem \
		-o orderer.example.com:7050 --tls --cafile tls/tlsca.example.com-cert.pem \
		-c '{"function":"InitLedger","Args":[]}'

sleep $DELAY

echo "query chaincode: $CC_NAME function: GetAllAssets"
docker exec ${COMPOSE_PROJECT_NAME}_cli-org1 \
	peer chaincode query --channelID $CHANNEL_NAME -n $CC_NAME \
	-c '{"Args":["GetAllAssets"]}'

