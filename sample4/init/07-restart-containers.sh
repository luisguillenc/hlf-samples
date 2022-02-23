#!/bin/bash

source .env

docker-compose restart explorer.org1.example.com
docker-compose restart app.org1.example.com
