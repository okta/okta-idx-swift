#!/bin/bash

if [[ -z $A18N_API_KEY ]]; then
    echo "No A18N API key"
    exit 1
fi

profile_url=$(jq -r .url A18NProfile.json)
if [[ -z $profile_url ]]; then
    echo "No A18N profile URL defined"
    exit 1
fi

curl -H "x-api-key: $A18N_API_KEY" -H "Accept: application/json" -X DELETE $profile_url
rm -f A18NProfile.json
