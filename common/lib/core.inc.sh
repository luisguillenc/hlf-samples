#!/bin/bash

function defined() { [ "${!1-X}" == "${!1-Y}" ] ; }
function die() { echo "error: $@" 1>&2 ; exit 1 ; }
function warn() { echo "warn: $@" 1>&2 ; }
function msg() { echo "$@" ; }
function step() { echo -n "* $@..." ; }
function step_ok() { echo " OK" ; }
function step_err() { if [ $# -ne 0 ]; then echo " ERROR: $@" ; else echo " ERROR" ; fi; }
