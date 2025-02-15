#!/bin/bash

ACCESS_TOKEN="${GH_TOKEN}"
GH_ORG="${GH_ORG}"

echo "ORG ${GH_ORG}"
echo "ACCESS_TOKEN ${ACCESS_TOKEN}"

REG_TOKEN=$(curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" https://api.github.com/orgs/${GH_ORG}/actions/runners/registration-token | jq .token --raw-output)

cd /home/docker/actions-runner

./config.sh --url https://github.com/${GH_ORG} --token ${REG_TOKEN}

cleanup() {
	echo "Removing runner..."
	./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh &
wait $!
