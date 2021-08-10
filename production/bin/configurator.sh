#!/bin/bash

set -e

echo "Starting configuration..."

if [[ -z ${GITHUB_TOKEN+x} || -z ${DEPLOY_ENV+x} || -z ${APP+x} ]]; then
	echo "GITHUB_TOKEN, DEPLOY_ENV and APP must be in the environment.   Exiting."
	exit 1
fi

cp config/cookies.json.example config/cookies.json

if [[ "$DEPLOY_ENV" != "qa" && "$DEPLOY_ENV" != "live" ]]; then
	# Only use the test configuration if we're not deploying to QA or Live, or running CI.
	echo "Copying test .env_file into place."
	cp .env_file.test .env_file
else
	# The dumb-init process expects an .env_file. Use an empty one for QA and Live.
	echo "Using SSM env vars instead of .env_file."
	touch .env_file
fi
