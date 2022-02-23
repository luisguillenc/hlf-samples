#!/bin/bash

if [ $# -lt 3 ]; then
	echo "channel name and peer name are required"
	exit 2
fi

CHANNEL_CONFIG=$1
CHANNEL_NAME=$2
ANCHOR_PEER=$3
PORT=7051

if [ ! -f $CHANNEL_CONFIG ]; then
	echo "file $CHANNEL_CONFIG doesn't exists"
	exit 2
fi

set -e

TMPDIR=$(mktemp -d)
cp $CHANNEL_CONFIG $TMPDIR/${CHANNEL_NAME}_config.block

pushd $TMPDIR &>/dev/null
configtxlator proto_decode --input ${CHANNEL_NAME}_config.block --type common.Block --output ${CHANNEL_NAME}_config.json
jq .data.data[0].payload.data.config ${CHANNEL_NAME}_config.json >config.json
jq '.channel_group.groups.Application.groups.'${CORE_PEER_LOCALMSPID}'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "'$ANCHOR_PEER'","port": '$PORT'}]},"version": "0"}}' config.json >modified_config.json
configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output config_update.pb
configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb
popd &>/dev/null

cp $TMPDIR/config_update_in_envelope.pb update_${CHANNEL_NAME}.tx
rm -rf $TMPDIR
echo "generated update_${CHANNEL_NAME}.tx"

