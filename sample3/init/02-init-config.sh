#!/bin/bash

source .env

set -e

DSTDIR=etc/orderer
mkdir -p $DSTDIR
cp $DATADIR/orderer.yaml $DSTDIR/
cp -rp artifacts/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/* $DSTDIR/
cp artifacts/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org2.example.com/msp/tlscacerts/tlsca.org2.example.com-cert.pem $DSTDIR/tls/

DSTDIR=etc/cli-org1
mkdir -p $DSTDIR
cp $DATADIR/core.yaml $DSTDIR/
cp -rp artifacts/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/* $DSTDIR/
cp artifacts/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org2.example.com/msp/tlscacerts/tlsca.org2.example.com-cert.pem $DSTDIR/tls/

DSTDIR=etc/cli-org2
mkdir -p $DSTDIR
cp $DATADIR/core.yaml $DSTDIR/
cp -rp artifacts/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/* $DSTDIR/
cp artifacts/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org2.example.com/msp/tlscacerts/tlsca.org2.example.com-cert.pem $DSTDIR/tls/

DSTDIR=etc/peer0-org1
mkdir -p $DSTDIR
cp $DATADIR/core.yaml $DSTDIR/
cp -rp artifacts/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/* $DSTDIR/
cp artifacts/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org2.example.com/msp/tlscacerts/tlsca.org2.example.com-cert.pem $DSTDIR/tls/

DSTDIR=etc/peer1-org1
mkdir -p $DSTDIR
cp $DATADIR/core.yaml $DSTDIR/
cp -rp artifacts/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/* $DSTDIR/
cp artifacts/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org2.example.com/msp/tlscacerts/tlsca.org2.example.com-cert.pem $DSTDIR/tls/

DSTDIR=etc/peer2-org1
mkdir -p $DSTDIR
cp $DATADIR/core.yaml $DSTDIR/
cp -rp artifacts/crypto-config/peerOrganizations/org1.example.com/peers/peer2.org1.example.com/* $DSTDIR/
cp artifacts/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org2.example.com/msp/tlscacerts/tlsca.org2.example.com-cert.pem $DSTDIR/tls/

DSTDIR=etc/peer0-org2
mkdir -p $DSTDIR
cp $DATADIR/core.yaml $DSTDIR/
cp -rp artifacts/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/* $DSTDIR/
cp artifacts/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org2.example.com/msp/tlscacerts/tlsca.org2.example.com-cert.pem $DSTDIR/tls/

DSTDIR=etc/peer1-org2
mkdir -p $DSTDIR
cp $DATADIR/core.yaml $DSTDIR/
cp -rp artifacts/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/* $DSTDIR/
cp artifacts/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org2.example.com/msp/tlscacerts/tlsca.org2.example.com-cert.pem $DSTDIR/tls/

DSTDIR=etc/peer2-org2
mkdir -p $DSTDIR
cp $DATADIR/core.yaml $DSTDIR/
cp -rp artifacts/crypto-config/peerOrganizations/org2.example.com/peers/peer2.org2.example.com/* $DSTDIR/
cp artifacts/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem $DSTDIR/tls/
cp artifacts/crypto-config/peerOrganizations/org2.example.com/msp/tlscacerts/tlsca.org2.example.com-cert.pem $DSTDIR/tls/

DSTDIR=etc/app-org1
mkdir -p $DSTDIR
cp $DATADIR/app-connection-org1.yaml $DSTDIR/connection-org1.yaml
cp -rp artifacts/crypto-config/peerOrganizations/org1.example.com/users/User1@org1.example.com/* $DSTDIR/

DSTDIR=etc/explorer-org1
mkdir -p $DSTDIR/crypto
cp $DATADIR/explorer-config.json $DSTDIR/config.json
cp $DATADIR/explorer-connection-org1.json $DSTDIR/connection-org1.json
cp -rp artifacts/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/* $DSTDIR/crypto/
cp artifacts/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem $DSTDIR/crypto/tls/
cp artifacts/crypto-config/peerOrganizations/org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem $DSTDIR/crypto/tls/
cp artifacts/crypto-config/peerOrganizations/org2.example.com/msp/tlscacerts/tlsca.org2.example.com-cert.pem $DSTDIR/crypto/tls/
