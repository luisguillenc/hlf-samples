#!/bin/bash

if [ $# -lt 1 ]; then
	echo "require package label_version"
	exit 2
fi

CC_LABEL=$1

peer lifecycle chaincode queryinstalled -O json | \
	jq '.installed_chaincodes[] | select(.label=="'$CC_LABEL'").package_id' -r -e

