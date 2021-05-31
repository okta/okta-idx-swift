#!/bin/bash

if [[ -z $OKTA_API_KEY ]]; then
    echo "No Org API key"
    exit 1
fi

if [[ -z $OKTA_DOMAIN ]]; then
    echo "No Domain"
    exit 1
fi

./scripts/oktamate users create -k $OKTA_API_KEY -d $OKTA_DOMAIN -g $PASSCODE_PASSWORD $PASSCODE_USERNAME
