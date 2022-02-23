#!/bin/bash

function die() { echo "error: $@" 1>&2 ; exit 1 ; }


if [ $# -ne 7 ]; then
        die "invalid number of params, example: $0 ca-org1 org1.example.com ca.org1.example.com 7054 adminpw ca-org1-tls.pem"
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

## create base of the organization for generate cert
FABRIC_CA_CLIENT_HOME=$(pwd)/fabric-ca-client/${domain}
mkdir -p $FABRIC_CA_CLIENT_HOME
export FABRIC_CA_CLIENT_HOME

## create base to put crypto materials
CRYPTO_CONFIG=$(pwd)/crypto-config/peerOrganizations/${domain}
mkdir -p $CRYPTO_CONFIG

echo "generating peer org $domain crypto-config from $caserver"


############################################
## 1. generate crypto materials using ca-client
###########################################

## generate random passwords
peer0pw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
peerAdminpw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
user1pw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

## enroll admin and register peer0, peerAdmin and user1
echo "+ enrolling admin in $caname"
fabric-ca-client enroll -u https://admin:${adminpw}@${caserver}:${caport} --caname $caname \
    --tls.certfiles $tlscertfiles

echo "+ registering peer0 in $caname"
fabric-ca-client register --caname $caname \
    --id.name peer0 --id.secret $peer0pw --id.type peer \
    --tls.certfiles $tlscertfiles

echo "+ registering peerAdmin in $caname"
fabric-ca-client register --caname $caname \
    --id.name peerAdmin --id.secret $peerAdminpw --id.type admin \
    --tls.certfiles $tlscertfiles

echo "+ registering user1 in $caname"
fabric-ca-client register --caname $caname \
    --id.name user1 --id.secret $user1pw --id.type client \
    --tls.certfiles $tlscertfiles


## if caname and tlscaname are different, then it's necesary to create identities in tlscacerts too
if [ "$caname" != "$tlscaname" ]; then
    echo "+ enrolling admin in $tlscaname"
    fabric-ca-client enroll -u https://admin:${adminpw}@${caserver}:${caport} --caname $tlscaname \
        --tls.certfiles $tlscertfiles

    echo "+ registering peer0 in $tlscaname"
    fabric-ca-client register --caname $tlscaname \
        --id.name peer0 --id.secret $peer0pw --id.type peer \
        --tls.certfiles $tlscertfiles

    ## register peer admin
    echo "+ registering peerAdmin in $tlscaname"
    fabric-ca-client register --caname $tlscaname \
        --id.name peerAdmin --id.secret $peerAdminpw --id.type admin \
        --tls.certfiles $tlscertfiles
        
    ## register peer user1
    echo "+ registering user1 in $tlscaname"
    fabric-ca-client register --caname $tlscaname \
        --id.name user1 --id.secret $user1pw --id.type client \
        --tls.certfiles $tlscertfiles
fi


## generate peer0 msp and tls
echo "+ enrolling peer0 msp in $caname"
fabric-ca-client enroll -u https://peer0:${peer0pw}@${caserver}:${caport} --caname $caname \
    --csr.hosts peer0.$domain -M peers/peer0.${domain}/msp \
    --tls.certfiles $tlscertfiles

echo "+ enrolling peer0 tls in $tlscaname"
fabric-ca-client enroll -u https://peer0:${peer0pw}@${caserver}:${caport} --caname $tlscaname \
    --csr.hosts peer0.${domain} -M peers/peer0.${domain}/tls --enrollment.profile tls \
    --tls.certfiles $tlscertfiles


## generate peer admin msp and tls
echo "+ enrolling peerAdmin msp in $caname"
fabric-ca-client enroll -u https://peerAdmin:${peerAdminpw}@${caserver}:${caport} --caname $caname \
    -M users/Admin@${domain}/msp \
    --tls.certfiles $tlscertfiles

echo "+ enrolling peerAdmin tls in $tlscaname"
fabric-ca-client enroll -u https://peerAdmin:${peerAdminpw}@${caserver}:${caport} --caname $tlscaname \
    -M users/Admin@${domain}/tls --enrollment.profile tls \
    --tls.certfiles $tlscertfiles


## generate peer user1 msp and tls
echo "+ enrolling user1 msp in $caname"
fabric-ca-client enroll -u https://user1:${user1pw}@${caserver}:${caport} --caname $caname \
    -M users/User1@${domain}/msp \
    --tls.certfiles $tlscertfiles

echo "+ enrolling user1 tls in $tlscaname"
fabric-ca-client enroll -u https://user1:${user1pw}@${caserver}:${caport} --caname $tlscaname \
    -M users/User1@${domain}/tls --enrollment.profile tls \
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


echo "+ generating peer0.$domain msp"
mkdir -p $destcrypto/peers/peer0.${domain}/msp/{admincerts,cacerts,keystore,signcerts,tlscacerts}
cp $origcrypto/peers/peer0.${domain}/msp/cacerts/* $destcrypto/peers/peer0.${domain}/msp/cacerts/${caserver}-cert.pem
if [ -d $origcrypto/peers/peer0.${domain}/msp/intermediatecerts ]; then
    mkdir -p $destcrypto/peers/peer0.${domain}/msp/intermediatecerts
    cp $origcrypto/peers/peer0.${domain}/msp/intermediatecerts/* $destcrypto/peers/peer0.${domain}/msp/intermediatecerts/${caserver}-cert.pem
fi
cp $origcrypto/peers/peer0.${domain}/tls/tlscacerts/* $destcrypto/peers/peer0.${domain}/msp/tlscacerts/tls${caserver}-cert.pem
if [ -d $origcrypto/peers/peer0.${domain}/tls/tlsintermediatecerts ]; then
    mkdir -p $destcrypto/peers/peer0.${domain}/msp/tlsintermediatecerts
    cp $origcrypto/peers/peer0.${domain}/tls/tlsintermediatecerts/* $destcrypto/peers/peer0.${domain}/msp/tlsintermediatecerts/tls${caserver}-cert.pem
fi
cp $origcrypto/peers/peer0.${domain}/msp/keystore/* $destcrypto/peers/peer0.${domain}/msp/keystore/priv_sk
cp $origcrypto/peers/peer0.${domain}/msp/signcerts/* $destcrypto/peers/peer0.${domain}/msp/signcerts/peer0.${domain}-cert.pem
cp $destcrypto/msp/config.yaml $destcrypto/peers/peer0.${domain}/msp/

echo "+ generating peer0.$domain tls"
mkdir -p $destcrypto/peers/peer0.${domain}/tls
rm -f $destcrypto/peers/peer0.${domain}/tls/ca.crt
if [ -d $origcrypto/peers/peer0.${domain}/tls/tlsintermediatecerts ]; then
    cat $origcrypto/peers/peer0.${domain}/tls/tlsintermediatecerts/* >>$destcrypto/peers/peer0.${domain}/tls/ca.crt
fi
cat $origcrypto/peers/peer0.${domain}/tls/tlscacerts/* >>$destcrypto/peers/peer0.${domain}/tls/ca.crt
cp $origcrypto/peers/peer0.${domain}/tls/signcerts/* $destcrypto/peers/peer0.${domain}/tls/server.crt
cp $origcrypto/peers/peer0.${domain}/tls/keystore/* $destcrypto/peers/peer0.${domain}/tls/server.key

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

echo "+ generating user1 msp"
mkdir -p $destcrypto/users/User1@${domain}/msp/{admincerts,cacerts,keystore,signcerts,tlscacerts}
cp $origcrypto/users/User1@${domain}/msp/cacerts/* $destcrypto/users/User1@${domain}/msp/cacerts/${caserver}-cert.pem
if [ -d $origcrypto/users/User1@${domain}/msp/intermediatecerts ]; then
    mkdir -p $destcrypto/users/User1@${domain}/msp/intermediatecerts
    cp $origcrypto/users/User1@${domain}/msp/intermediatecerts/* $destcrypto/users/User1@${domain}/msp/intermediatecerts/${caserver}-cert.pem
fi
cp $origcrypto/users/User1@${domain}/tls/tlscacerts/* $destcrypto/users/User1@${domain}/msp/tlscacerts/tls${caserver}-cert.pem
if [ -d $origcrypto/users/User1@${domain}/tls/tlsintermediatecerts ]; then
    mkdir -p $destcrypto/users/User1@${domain}/msp/tlsintermediatecerts
    cp $origcrypto/users/User1@${domain}/tls/tlsintermediatecerts/* $destcrypto/users/User1@${domain}/msp/tlsintermediatecerts/tls${caserver}-cert.pem
fi
cp $origcrypto/users/User1@${domain}/msp/keystore/* $destcrypto/users/User1@${domain}/msp/keystore/priv_sk
cp $origcrypto/users/User1@${domain}/msp/signcerts/* $destcrypto/users/User1@${domain}/msp/signcerts/User1@${domain}-cert.pem
cp $destcrypto/msp/config.yaml $destcrypto/users/User1@${domain}/msp/

echo "+ generating user1 tls"
mkdir -p $destcrypto/users/User1@${domain}/tls
rm -f $destcrypto/users/User1@${domain}/tls/ca.crt
if [ -d $origcrypto/users/User1@${domain}/tls/tlsintermediatecerts ]; then
    cat $origcrypto/users/User1@${domain}/tls/tlsintermediatecerts/* >>$destcrypto/users/User1@${domain}/tls/ca.crt
fi
cat $origcrypto/users/User1@${domain}/tls/tlscacerts/* >>$destcrypto/users/User1@${domain}/tls/ca.crt
cp $origcrypto/users/User1@${domain}/tls/signcerts/* $destcrypto/users/User1@${domain}/tls/client.crt
cp $origcrypto/users/User1@${domain}/tls/keystore/* $destcrypto/users/User1@${domain}/tls/client.key


echo "crypto config generated in $CRYPTO_CONFIG"
