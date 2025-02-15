#!/bin/bash

if [ -f .env ]; then
	while IFS= read -r line || [ -n "$line" ]; do
		if [[ -z "$line" || "$line" =~ ^# ]]; then
			continue
		fi

		env_var=$(echo "$line" | sed 's/: /=/g')

		eval "export $env_var"
	done <.env
else
	echo ".env file not found!"
	exit 1
fi

ID_LIST=$(curl -s -L \
	-H "Accept: application/vnd.github+json" \
	-H "Authorization: Bearer ${GH_TOKEN}" \
	-H "X-GitHub-Api-Version: 2022-11-28" \
	https://api.github.com/orgs/${GH_ORG}/actions/runners | jq .runners | jq '.[]' | jq .id)

for id in ${ID_LIST}; do
	curl -L -X DELETE \
		-H "Accept: application/vnd.github+json" \
		-H "Authorization: Bearer ${GH_TOKEN}" \
		-H "X-GitHub-Api-Version: 2022-11-28" \
		https://api.github.com/orgs/${GH_ORG}/actions/runners/${id}
done
