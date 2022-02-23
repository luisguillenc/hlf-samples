#!/bin/bash

source .env

set -e

docker-compose build
docker-compose up -d
