#!/bin/bash

source .env

set -e

mkdir -p artifacts
cp $DATADIR/configtx.yaml artifacts/

echo "create genesis block"
docker run -it --rm -v $PWD/artifacts:/work -w /work -u $UID  hyperledger/fabric-tools:2.2.2 \
	configtxgen -profile TwoOrgsOrdererGenesis -configPath=. -channelID system-channel -outputBlock genesisblock

## copy genesis to orderer
cp artifacts/genesisblock etc/orderer/

