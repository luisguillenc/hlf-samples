#!/bin/bash

source .env

CC_NAME="basic"
CC_VERSION="1.0"
CC_LABEL="${CC_NAME}_${CC_VERSION}"

set -e

mkdir -p artifacts
cp -r $CHAINCODESDIR/basic artifacts/

echo "packaging chaincode"
docker exec ${COMPOSE_PROJECT_NAME}_cli-org1 \
	peer lifecycle chaincode package $CC_NAME.tar.gz --path ./${CC_NAME}/ --lang golang --label $CC_LABEL

echo "installing chaincode in peer0.org1.example.com"
docker exec ${COMPOSE_PROJECT_NAME}_cli-org1 \
	peer lifecycle chaincode install $CC_NAME.tar.gz

echo "installing chaincode in peer0.org2.example.com"
docker exec ${COMPOSE_PROJECT_NAME}_cli-org2 \
	peer lifecycle chaincode install $CC_NAME.tar.gz
