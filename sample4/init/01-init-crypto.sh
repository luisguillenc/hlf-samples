#!/bin/bash

source .env

set -e

mkdir -p artifacts
cp $DATADIR/crypto-config.yaml artifacts/

## create cryptoconfig
echo "create cryptoconfig"
#docker run -it --rm -v $PWD/artifacts:/work -w /work -u $UID  hyperledger/fabric-tools:$IMAGE_TAG \
#	cryptogen generate --config ./crypto-config.yaml

## required use hacked version of cryptogen: https://jira.hyperledger.org/browse/FAB-17221
pushd artifacts >/dev/null
mycryptogen generate --config ./crypto-config.yaml
popd >/dev/null
