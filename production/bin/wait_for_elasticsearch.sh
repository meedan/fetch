#!/bin/bash

set -a
source .env_file
set +a

echo "Waiting for ElasticSearch to become available..."
until curl --silent -XGET --fail ${es_host}; do printf '.'; sleep 1; done
echo "Finished waiting."
echo ""
echo "Available indexes:"
curl ${es_host}/_aliases?pretty=true
