#!/bin/bash

PORT=8080
DELAY=5

set -e

echo "getting assests"
curl -X GET -H "Accept: application/json" "http://localhost:$PORT/assets"

echo ""

echo "creating asset"
curl -X POST -H "Content-Type: application/json" \
	-d '{"ID":"asset69","color":"marron","size":69,"owner":"Manolo","appraisedValue":300}' \
	"http://localhost:$PORT/assets"

echo ""

echo "getting assests"
curl -X GET -H "Accept: application/json" "http://localhost:$PORT/assets"

echo ""
