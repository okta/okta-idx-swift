#!/bin/bash

if [[ -z $A18N_API_KEY ]]; then
    echo "No A18N API key"
    exit 1
fi

if [[ -n $A18N_PROFILE_ID ]]; then
    echo "An A18N profile ID is already set; skipping setup"
    exit 0
fi

if [[ -f A18NProfile.json ]]; then
    echo "A18NProfile.json already exists!"
    exit 1
fi

curl -H "x-api-key: $A18N_API_KEY" \
     -H "Accept: application/json" \
     -X POST \
     https://api.a18n.help/v1/profile > A18NProfile.json

echo -n "A18N_PROFILE_ID = " >> TestCredentials.xcconfig
jq -r .profileId A18NProfile.json >> TestCredentials.xcconfig
