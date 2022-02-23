#!/bin/bash

## define required variables
SAMPLEDIR=$(dirname $(readlink -f "$0"))
BASEDIR=$(dirname $SAMPLEDIR)

## include libs
. $BASEDIR/common/lib/core.inc.sh
. $BASEDIR/common/lib/samples.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"

pushd $WORKDIR>/dev/null
docker-compose down -v
popd>/dev/null

## do clean
clean_workdir

