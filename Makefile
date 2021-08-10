SHELL := /bin/bash

configurator:
	production/bin/configurator.sh

start_server: configurator
	set -o allexport && source .env_file && set +o allexport && bundle exec rake safe_init_index && bundle exec rackup -o 0.0.0.0

collect_all: configurator
	set -o allexport && source .env_file && set +o allexport && bundle exec rake collect_all

run_worker: configurator
	set -o allexport && source .env_file && set +o allexport && bundle exec rake requeue && bundle exec sidekiq -r ./environment.rb -c 5

test: configurator
	bundle exec rake test

test_unit: configurator
	bundle exec rake test:unit

test_unit_fork:
	bundle exec rake test:unit

test_integration: configurator
	echo "Waiting for ElasticSearch to be available..."
        until curl --silent -XGET --fail http://elasticsearch:9200/; do printf '.'; sleep 1; done
	echo "Wait finished. Starting integration tests..."
	curl http://elasticsearch:9200/_aliases?pretty=true
	bundle exec rake test:integration
