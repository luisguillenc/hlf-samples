#!/bin/bash

source .env
CHANNEL_NAME="test-channel"

set -e

mkdir -p artifacts
cp $UTILSDIR/createUpdateAnchorPeerTx.sh artifacts/

echo "setting peer0.org1.example.com as anchor peer to channel"
docker exec -e CORE_PEER_TLS_CLIENTAUTHREQUIRED=true \
            -e CORE_PEER_TLS_CLIENTCERT_FILE=tls/client.crt \
            -e CORE_PEER_TLS_CLIENTKEY_FILE=tls/client.key  \
            ${COMPOSE_PROJECT_NAME}_cli-org1 \
    peer channel fetch config -c ${CHANNEL_NAME}

docker exec -e CORE_PEER_TLS_CLIENTAUTHREQUIRED=true \
            -e CORE_PEER_TLS_CLIENTCERT_FILE=tls/client.crt \
            -e CORE_PEER_TLS_CLIENTKEY_FILE=tls/client.key  \
            ${COMPOSE_PROJECT_NAME}_cli-org1 \
    ./createUpdateAnchorPeerTx.sh ${CHANNEL_NAME}_config.block $CHANNEL_NAME peer0.org1.example.com

docker exec -e CORE_PEER_TLS_CLIENTAUTHREQUIRED=true \
            -e CORE_PEER_TLS_CLIENTCERT_FILE=tls/client.crt \
            -e CORE_PEER_TLS_CLIENTKEY_FILE=tls/client.key  \
            ${COMPOSE_PROJECT_NAME}_cli-org1 \
    peer channel update -f update_${CHANNEL_NAME}.tx -c $CHANNEL_NAME \
        -o orderer.example.com:7050 --tls --cafile tls/tlsca.example.com-cert.pem \
        --clientauth --certfile tls/client.crt --keyfile tls/client.key

echo "setting peer0.org2.example.com as anchor peer to channel"
docker exec -e CORE_PEER_TLS_CLIENTAUTHREQUIRED=true \
            -e CORE_PEER_TLS_CLIENTCERT_FILE=tls/client.crt \
            -e CORE_PEER_TLS_CLIENTKEY_FILE=tls/client.key  \
            ${COMPOSE_PROJECT_NAME}_cli-org2 \
    peer channel fetch config -c ${CHANNEL_NAME}

docker exec -e CORE_PEER_TLS_CLIENTAUTHREQUIRED=true \
            -e CORE_PEER_TLS_CLIENTCERT_FILE=tls/client.crt \
            -e CORE_PEER_TLS_CLIENTKEY_FILE=tls/client.key  \
            ${COMPOSE_PROJECT_NAME}_cli-org2 \
    ./createUpdateAnchorPeerTx.sh ${CHANNEL_NAME}_config.block $CHANNEL_NAME peer0.org2.example.com

docker exec -e CORE_PEER_TLS_CLIENTAUTHREQUIRED=true \
            -e CORE_PEER_TLS_CLIENTCERT_FILE=tls/client.crt \
            -e CORE_PEER_TLS_CLIENTKEY_FILE=tls/client.key  \
            ${COMPOSE_PROJECT_NAME}_cli-org2 \
    peer channel update -f update_${CHANNEL_NAME}.tx -c $CHANNEL_NAME \
        -o orderer.example.com:7050 --tls --cafile tls/tlsca.example.com-cert.pem \
        --clientauth --certfile tls/client.crt --keyfile tls/client.key
