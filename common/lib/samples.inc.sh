#!/bin/bash

defined BASEDIR || die "BASEDIR is required"
defined SAMPLEDIR || die "SAMPLEDIR is required"

## set some defaults
defined SAMPLENAME || SAMPLENAME=$(basename $SAMPLEDIR)
defined WORKDIR  || WORKDIR=$SAMPLEDIR/work
defined DATADIR  || DATADIR=$SAMPLEDIR/data
defined COMMONDIR || COMMONDIR=$BASEDIR/common
defined CHAINCODESDIR || CHAINCODESDIR=$BASEDIR/common/chaincodes
defined APPSDIR  || APPSDIR=$BASEDIR/common/apps
defined UTILSDIR || UTILSDIR=$BASEDIR/common/utils

function create_workdir() {
    mkdir -p $WORKDIR || return $?
}

function clean_workdir() {
    [ "$WORKDIR" == "/" ] && die "¡fatal! WORKDIR == /"
    rm -rf $WORKDIR
}

function exists_workdir() {
    [ -d $WORKDIR ]
}
