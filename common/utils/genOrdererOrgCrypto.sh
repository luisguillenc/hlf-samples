#!/bin/bash

function die() { echo "error: $@" 1>&2 ; exit 1 ; }


if [ $# -ne 7 ]; then
        die "invalid number of params, example: $0 ca-msp ca-tls example.com ca.example.com 7054 adminpw ca-orderer-tls.pem"
fi

caname=$1
tlscaname=$2
domain=$3
caserver=$4
caport=$5
adminpw=$6
tlscertfiles=$7
[ -f $tlscertfiles ] || die "$tlscertfiles not found!"
tlscertfiles=$(readlink -f $tlscertfiles)

set -e

FABRIC_CA_CLIENT_HOME=$(pwd)/fabric-ca-client/${domain}
mkdir -p $FABRIC_CA_CLIENT_HOME
export FABRIC_CA_CLIENT_HOME

## create base to put crypto materials
CRYPTO_CONFIG=$(pwd)/crypto-config/ordererOrganizations/${domain}
mkdir -p $CRYPTO_CONFIG

echo "generating orderer org $domain crypto-config from $caserver"


############################################
## 1. generate crypto materials using ca-client
###########################################

## generate random passwords
ordererpw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
ordererAdminpw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

## enroll admin and register orderer
echo "+ enrolling admin in $caname"
fabric-ca-client enroll -u https://admin:${adminpw}@${caserver}:${caport} --caname $caname \
    --tls.certfiles $tlscertfiles

echo "+ registering orderer in $caname"
fabric-ca-client register --caname $caname \
    --id.name orderer --id.secret $ordererpw --id.type orderer \
    --tls.certfiles $tlscertfiles

echo "+ registering ordererAdmin in $caname"
fabric-ca-client register --caname $caname \
    --id.name ordererAdmin --id.secret $ordererAdminpw --id.type admin \
    --tls.certfiles $tlscertfiles

## if caname and tlscaname are different, then it's necesary to create identities in tlscacerts too
if [ "$caname" != "$tlscaname" ]; then
    echo "+ enrolling admin in $tlscaname"
    fabric-ca-client enroll -u https://admin:${adminpw}@${caserver}:${caport} --caname $tlscaname \
        --tls.certfiles $tlscertfiles
        
    echo "+ registering orderer in $tlscaname"
    fabric-ca-client register --caname $tlscaname \
        --id.name orderer --id.secret $ordererpw --id.type orderer \
        --tls.certfiles $tlscertfiles

    echo "+ registering ordererAdmin in $tlscaname"
    fabric-ca-client register --caname $tlscaname \
        --id.name ordererAdmin --id.secret $ordererAdminpw --id.type admin \
        --tls.certfiles $tlscertfiles
fi

## generate orderer msp and tls
echo "+ enrolling orderer msp in $caname"
fabric-ca-client enroll -u https://orderer:${ordererpw}@${caserver}:${caport} --caname $caname \
    --csr.hosts orderer.$domain -M orderers/orderer.${domain}/msp \
    --tls.certfiles $tlscertfiles

echo "+ enrolling orderer tls in $tlscaname"
fabric-ca-client enroll -u https://orderer:${ordererpw}@${caserver}:${caport} --caname $tlscaname \
    --csr.hosts orderer.${domain} -M orderers/orderer.${domain}/tls --enrollment.profile tls \
    --tls.certfiles $tlscertfiles


## generate orderer admin msp and tls
echo "+ enrolling ordererAdmin msp in $caname"
fabric-ca-client enroll -u https://ordererAdmin:${ordererAdminpw}@${caserver}:${caport} --caname $caname \
    -M users/Admin@${domain}/msp \
    --tls.certfiles $tlscertfiles

echo "+ enrolling ordererAdmin tls in $caname"
fabric-ca-client enroll -u https://ordererAdmin:${ordererAdminpw}@${caserver}:${caport} --caname $tlscaname \
    -M users/Admin@${domain}/tls --enrollment.profile tls \
    --tls.certfiles $tlscertfiles


########################################
## 2. copy generated files to crypto-config
########################################
origcrypto=$FABRIC_CA_CLIENT_HOME
destcrypto=$CRYPTO_CONFIG
    
## create crypto-config for domain
echo "+ generating org $domain msp"
mkdir -p $destcrypto/msp/{admincerts,cacerts,tlscacerts}
cp $origcrypto/msp/cacerts/*-${caport}-${caname}.pem $destcrypto/msp/cacerts/${caserver}-cert.pem
cp $origcrypto/msp/cacerts/*-${caport}-${tlscaname}.pem $destcrypto/msp/tlscacerts/tls${caserver}-cert.pem
if [ -d $origcrypto/msp/intermediatecerts ]; then
    mkdir -p $destcrypto/msp/{intermediatecerts,tlsintermediatecerts}
    cp $origcrypto/msp/intermediatecerts/*-${caport}-${caname}.pem $destcrypto/msp/intermediatecerts/${caserver}-cert.pem
    cp $origcrypto/msp/intermediatecerts/*-${caport}-${tlscaname}.pem $destcrypto/msp/tlsintermediatecerts/tls${caserver}-cert.pem
fi

cat >$destcrypto/msp/config.yaml <<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    #Certificate: cacerts/${caserver}-cert.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    #Certificate: cacerts/${caserver}-cert.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    #Certificate: cacerts/${caserver}-cert.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    #Certificate: cacerts/${caserver}-cert.pem
    OrganizationalUnitIdentifier: orderer
EOF

echo "+ generating org $domain tls (certificate chain)"
mkdir -p $destcrypto/tls
rm -f $destcrypto/tls/ca.crt
if [ -d $destcrypto/msp/tlsintermediatecerts ]; then
    cat $destcrypto/msp/tlsintermediatecerts/* >>$destcrypto/tls/ca.crt
fi
cat $destcrypto/msp/tlscacerts/* >>$destcrypto/tls/ca.crt


echo "+ generating orderer.$domain msp"
mkdir -p $destcrypto/orderers/orderer.${domain}/msp/{admincerts,cacerts,keystore,signcerts,tlscacerts}
cp $origcrypto/orderers/orderer.${domain}/msp/cacerts/* $destcrypto/orderers/orderer.${domain}/msp/cacerts/${caserver}-cert.pem
if [ -d $origcrypto/orderers/orderer.${domain}/msp/intermediatecerts ]; then
    mkdir -p $destcrypto/orderers/orderer.${domain}/msp/intermediatecerts
    cp $origcrypto/orderers/orderer.${domain}/msp/intermediatecerts/* $destcrypto/orderers/orderer.${domain}/msp/intermediatecerts/${caserver}-cert.pem
fi
cp $origcrypto/orderers/orderer.${domain}/tls/tlscacerts/* $destcrypto/orderers/orderer.${domain}/msp/tlscacerts/tls${caserver}-cert.pem
if [ -d $origcrypto/orderers/orderer.${domain}/tls/tlsintermediatecerts ]; then
    mkdir -p $destcrypto/orderers/orderer.${domain}/msp/tlsintermediatecerts
    cp $origcrypto/orderers/orderer.${domain}/tls/tlsintermediatecerts/* $destcrypto/orderers/orderer.${domain}/msp/tlsintermediatecerts/tls${caserver}-cert.pem
fi
cp $origcrypto/orderers/orderer.${domain}/msp/keystore/* $destcrypto/orderers/orderer.${domain}/msp/keystore/priv_sk
cp $origcrypto/orderers/orderer.${domain}/msp/signcerts/* $destcrypto/orderers/orderer.${domain}/msp/signcerts/orderer.${domain}-cert.pem
cp $destcrypto/msp/config.yaml $destcrypto/orderers/orderer.${domain}/msp/

echo "+ generating orderer.$domain tls"
mkdir -p $destcrypto/orderers/orderer.${domain}/tls
rm -f $destcrypto/orderers/orderer.${domain}/tls/ca.crt
if [ -d $origcrypto/orderers/orderer.${domain}/tls/tlsintermediatecerts ]; then
    cat $origcrypto/orderers/orderer.${domain}/tls/tlsintermediatecerts/* >>$destcrypto/orderers/orderer.${domain}/tls/ca.crt
fi
cat $origcrypto/orderers/orderer.${domain}/tls/tlscacerts/* >>$destcrypto/orderers/orderer.${domain}/tls/ca.crt
cp $origcrypto/orderers/orderer.${domain}/tls/signcerts/* $destcrypto/orderers/orderer.${domain}/tls/server.crt
cp $origcrypto/orderers/orderer.${domain}/tls/keystore/* $destcrypto/orderers/orderer.${domain}/tls/server.key

echo "+ generating ordererAdmin msp"
mkdir -p $destcrypto/users/Admin@${domain}/msp/{admincerts,cacerts,keystore,signcerts,tlscacerts}
cp $origcrypto/users/Admin@${domain}/msp/cacerts/* $destcrypto/users/Admin@${domain}/msp/cacerts/${caserver}-cert.pem
if [ -d $origcrypto/users/Admin@${domain}/msp/intermediatecerts ]; then
    mkdir -p $destcrypto/users/Admin@${domain}/msp/intermediatecerts
    cp $origcrypto/users/Admin@${domain}/msp/intermediatecerts/* $destcrypto/users/Admin@${domain}/msp/intermediatecerts/${caserver}-cert.pem
fi
cp $origcrypto/users/Admin@${domain}/tls/tlscacerts/* $destcrypto/users/Admin@${domain}/msp/tlscacerts/tls${caserver}-cert.pem
if [ -d $origcrypto/users/Admin@${domain}/tls/tlsintermediatecerts ]; then
    mkdir -p $destcrypto/users/Admin@${domain}/msp/tlsintermediatecerts
    cp $origcrypto/users/Admin@${domain}/tls/tlsintermediatecerts/* $destcrypto/users/Admin@${domain}/msp/tlsintermediatecerts/tls${caserver}-cert.pem
fi
cp $origcrypto/users/Admin@${domain}/msp/keystore/* $destcrypto/users/Admin@${domain}/msp/keystore/priv_sk
cp $origcrypto/users/Admin@${domain}/msp/signcerts/* $destcrypto/users/Admin@${domain}/msp/signcerts/Admin@${domain}-cert.pem
cp $destcrypto/msp/config.yaml $destcrypto/users/Admin@${domain}/msp/

echo "+ generating ordererAdmin tls"
mkdir -p $destcrypto/users/Admin@${domain}/tls
rm -f $destcrypto/users/Admin@${domain}/tls/ca.crt
if [ -d $origcrypto/users/Admin@${domain}/tls/tlsintermediatecerts ]; then
    cat $origcrypto/users/Admin@${domain}/tls/tlsintermediatecerts/* >>$destcrypto/users/Admin@${domain}/tls/ca.crt
fi
cat $origcrypto/users/Admin@${domain}/tls/tlscacerts/* >>$destcrypto/users/Admin@${domain}/tls/ca.crt
cp $origcrypto/users/Admin@${domain}/tls/signcerts/* $destcrypto/users/Admin@${domain}/tls/client.crt
cp $origcrypto/users/Admin@${domain}/tls/keystore/* $destcrypto/users/Admin@${domain}/tls/client.key

echo "crypto config generated in $CRYPTO_CONFIG"
