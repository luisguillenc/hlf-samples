#!/bin/bash

source .env
CHANNEL_NAME="test-channel"

set -e

echo "joining peer0.org1.example.com to channel"
docker exec ${COMPOSE_PROJECT_NAME}_cli-org1 \
	peer channel join -b ./${CHANNEL_NAME}.block

echo "joining peer1.org1.example.com to channel"
docker exec -e CORE_PEER_ID=peer1.org1.example.com -e CORE_PEER_ADDRESS=peer1.org1.example.com:7051 ${COMPOSE_PROJECT_NAME}_cli-org1 \
	peer channel join -b ./${CHANNEL_NAME}.block

echo "joining peer2.org1.example.com to channel"
docker exec -e CORE_PEER_ID=peer2.org1.example.com -e CORE_PEER_ADDRESS=peer2.org1.example.com:7051 ${COMPOSE_PROJECT_NAME}_cli-org1 \
	peer channel join -b ./${CHANNEL_NAME}.block

# we can join from peer using admin msp
#docker exec -e CORE_PEER_MSPCONFIGPATH=/work/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp \
#	prueba3_peer0.org1.example.com_1 \
#	peer channel join -b ./${CHANNEL_NAME}.block
#

echo "joining peer0.org2.example.com to channel"
docker exec ${COMPOSE_PROJECT_NAME}_cli-org2 \
	peer channel join -b ./${CHANNEL_NAME}.block

echo "joining peer1.org2.example.com to channel"
docker exec -e CORE_PEER_ID=peer1.org2.example.com -e CORE_PEER_ADDRESS=peer1.org2.example.com:7051 ${COMPOSE_PROJECT_NAME}_cli-org2 \
	peer channel join -b ./${CHANNEL_NAME}.block
	
echo "joining peer2.org2.example.com to channel"
docker exec -e CORE_PEER_ID=peer2.org2.example.com -e CORE_PEER_ADDRESS=peer2.org2.example.com:7051 ${COMPOSE_PROJECT_NAME}_cli-org2 \
	peer channel join -b ./${CHANNEL_NAME}.block
	
# we can join from peer using admin msp
#docker exec -e CORE_PEER_MSPCONFIGPATH=/work/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp \
#	prueba3_peer0.org2.example.com_1 \
#	peer channel join -b ./${CHANNEL_NAME}.block
#
