#!/bin/bash

source .env
CHANNEL_NAME="test-channel"

set -e

mkdir -p artifacts
cp $DATADIR/configtx.yaml artifacts/

echo "create channel transaction"
docker run -it --rm -v $PWD/artifacts:/work -w /work -u $UID  hyperledger/fabric-tools:$IMAGE_TAG \
	configtxgen -profile TwoOrgsChannel -configPath=. -outputCreateChannelTx ${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME

echo "exec transaction"
docker exec ${COMPOSE_PROJECT_NAME}_cli-org1 \
	peer channel create -c $CHANNEL_NAME -f ./${CHANNEL_NAME}.tx --outputBlock ./${CHANNEL_NAME}.block \
		-o orderer.example.com:7050 --tls --cafile tls/tlsca.example.com-cert.pem \
		--clientauth --certfile tls/client.crt --keyfile tls/client.key

