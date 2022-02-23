#!/bin/bash

## define required variables
SAMPLEDIR=$(dirname $(readlink -f "$0"))
BASEDIR=$(dirname $SAMPLEDIR)

## include libs
. $BASEDIR/common/lib/core.inc.sh
. $BASEDIR/common/lib/samples.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
[ -f $WORKDIR/.ready ] || die "sample was initialized with errors"

## start services
pushd $WORKDIR>/dev/null
docker-compose up -d
ecode=$?
popd>/dev/null

exit $ecode
