#!/bin/bash

## if arg1 == "-n" no stop containers
DO_STOP="yes"
[ "$1" == "-n" ] && DO_STOP="no"

## define required variables
SAMPLEDIR=$(dirname $(readlink -f "$0"))
BASEDIR=$(dirname $SAMPLEDIR)

## include libs
. $BASEDIR/common/lib/core.inc.sh
. $BASEDIR/common/lib/samples.inc.sh

## sanity checks
exists_workdir && die "workdir exists"

## do prepare
prepare_workdir() {
    mkdir -p $WORKDIR/artifacts
    cp $DATADIR/docker-compose.yaml $WORKDIR/ || return $?
    cp $SAMPLEDIR/init/* $WORKDIR/
    # generate .env
    echo "COMPOSE_PROJECT_NAME=hlf2-${SAMPLENAME}" >$WORKDIR/.env
    echo "IMAGE_TAG=2.2.2"  >>$WORKDIR/.env
    echo "DATADIR=$DATADIR" >>$WORKDIR/.env
    echo "CHAINCODESDIR=$CHAINCODESDIR" >>$WORKDIR/.env
    echo "APPSDIR=$APPSDIR"   >>$WORKDIR/.env
    echo "UTILSDIR=$UTILSDIR" >>$WORKDIR/.env
}

## prepare
create_workdir || die "creating workdir"
prepare_workdir || die "prepare workdir"
## run init scripts
pushd $WORKDIR>/dev/null
for initscript in *.sh; do
    msg "running $initscript"
    ./$initscript
    if [ $? -ne 0 ]; then
        popd >/dev/null
        die "processing $initscript"
    fi
done
touch $WORKDIR/.ready
[ "$DO_STOP" == "yes" ] && docker-compose stop
popd>/dev/null
