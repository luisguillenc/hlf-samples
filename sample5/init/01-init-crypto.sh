#!/bin/bash

source .env

## include libs
. $LIBDIR/core.inc.sh
. $LIBDIR/templates.inc.sh

mkdir -p artifacts
cp $UTILSDIR/genOrdererOrgCrypto.sh artifacts
cp $UTILSDIR/genPeerOrgCrypto.sh artifacts


#########
ORG_CODE=orderer
ORG_NAME=Orderer
DOMAIN=example.com
ADMIN_PW=adminpw

msg "starting ca-${ORG_CODE} server and waiting for tls-cert"
mkdir -p etc/ca-${ORG_CODE}
docker-compose up -d ca.$DOMAIN
while : ; do
	if [ ! -f "etc/ca-${ORG_CODE}/tls-cert.pem" ]; then
		sleep 1
    else
        cp etc/ca-${ORG_CODE}/tls-cert.pem artifacts/ca-${ORG_CODE}-tls.pem		
        break
	fi
done

msg "generating crypto material from ca-${ORG_CODE}"
docker run -it --rm -v $PWD/artifacts:/work -w /work -u $UID --network ${COMPOSE_PROJECT_NAME}_test hyperledger/fabric-ca:$CA_IMAGE_TAG \
    ./genOrdererOrgCrypto.sh ${ORG_CODE}-ca ${ORG_CODE}-ca $DOMAIN ca.${DOMAIN} 7054 $ADMIN_PW ca-${ORG_CODE}-tls.pem \
        || die "can't generate crypto for ${ORG_NAME}"


#########
ORG_CODE=org1
ORG_NAME=Org1
DOMAIN=org1.example.com
ADMIN_PW=adminpw

msg "starting ca-${ORG_CODE} server and waiting for tls-cert"
mkdir -p etc/ca-${ORG_CODE}
docker-compose up -d ca.$DOMAIN
while : ; do
	if [ ! -f "etc/ca-${ORG_CODE}/tls-cert.pem" ]; then
		sleep 1
    else
        cp etc/ca-${ORG_CODE}/tls-cert.pem artifacts/ca-${ORG_CODE}-tls.pem		
        break
	fi
done

msg "generating crypto material from ca-${ORG_CODE}"
docker run -it --rm -v $PWD/artifacts:/work -w /work -u $UID --network ${COMPOSE_PROJECT_NAME}_test hyperledger/fabric-ca:$CA_IMAGE_TAG \
    ./genPeerOrgCrypto.sh ${ORG_CODE}-ca ${ORG_CODE}-ca $DOMAIN ca.${DOMAIN} 7054 $ADMIN_PW ca-${ORG_CODE}-tls.pem \
        || die "can't generate crypto for ${ORG_NAME}"


#########
ORG_CODE=org2
ORG_NAME=Org2
DOMAIN=org2.example.com
ADMIN_PW=adminpw

msg "starting ca-${ORG_CODE} server and waiting for tls-cert"
mkdir -p etc/ca-${ORG_CODE}
docker-compose up -d ca.$DOMAIN
while : ; do
	if [ ! -f "etc/ca-${ORG_CODE}/tls-cert.pem" ]; then
		sleep 1
    else
        cp etc/ca-${ORG_CODE}/tls-cert.pem artifacts/ca-${ORG_CODE}-tls.pem		
        break
	fi
done

msg "generating crypto material from ca-${ORG_CODE}"
docker run -it --rm -v $PWD/artifacts:/work -w /work -u $UID --network ${COMPOSE_PROJECT_NAME}_test hyperledger/fabric-ca:$CA_IMAGE_TAG \
    ./genPeerOrgCrypto.sh ${ORG_CODE}-ca ${ORG_CODE}-ca $DOMAIN ca.${DOMAIN} 7054 $ADMIN_PW ca-${ORG_CODE}-tls.pem \
        || die "can't generate crypto for ${ORG_NAME}"
