#!/bin/bash

source .env
CHANNEL_NAME="test-channel"

set -e

echo "joining peer0.org1.example.com to channel"
docker exec ${COMPOSE_PROJECT_NAME}_cli-org1 \
	peer channel join -b ./${CHANNEL_NAME}.block

echo "joining peer0.org2.example.com to channel"
docker exec ${COMPOSE_PROJECT_NAME}_cli-org2 \
	peer channel join -b ./${CHANNEL_NAME}.block
