#!/bin/bash

source .env
CHANNEL_NAME="test-channel"

set -e

mkdir -p artifacts
cp $UTILSDIR/createUpdateAnchorPeerTx.sh artifacts/

echo "setting peer0.org1.example.com as anchor peer to channel"
docker exec ${COMPOSE_PROJECT_NAME}_cli-org1 \
	peer channel fetch config -c ${CHANNEL_NAME}

docker exec ${COMPOSE_PROJECT_NAME}_cli-org1 \
	./createUpdateAnchorPeerTx.sh ${CHANNEL_NAME}_config.block $CHANNEL_NAME peer0.org1.example.com

docker exec ${COMPOSE_PROJECT_NAME}_cli-org1 \
	peer channel update -f update_${CHANNEL_NAME}.tx -c $CHANNEL_NAME \
		-o orderer.example.com:7050 --tls --cafile tls/tlsca.example.com-cert.pem

echo "setting peer0.org2.example.com as anchor peer to channel"
docker exec ${COMPOSE_PROJECT_NAME}_cli-org2 \
	peer channel fetch config -c ${CHANNEL_NAME}

docker exec ${COMPOSE_PROJECT_NAME}_cli-org2 \
	./createUpdateAnchorPeerTx.sh ${CHANNEL_NAME}_config.block $CHANNEL_NAME peer0.org2.example.com

docker exec ${COMPOSE_PROJECT_NAME}_cli-org2 \
	peer channel update -f update_${CHANNEL_NAME}.tx -c $CHANNEL_NAME \
		-o orderer.example.com:7050 --tls --cafile tls/tlsca.example.com-cert.pem

