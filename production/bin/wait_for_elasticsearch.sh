#!/bin/bash
echo "Waiting for ElasticSearch to become available..."
until curl --silent -XGET --fail $(ELASTICSEARCH_URL); do printf '.'; sleep 1; done
echo "Finished waiting."
echo ""
echo "Available indexes:"
curl http://elasticsearch:9200/_aliases?pretty=true
