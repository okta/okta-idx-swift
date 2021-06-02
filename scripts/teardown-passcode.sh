#!/bin/bash

# Delete user if it exists to not fail the script
existing_user=$(oktamate users | grep $PASSCODE_USERNAME)
if [[ -n $existing_user ]]; then
    oktamate users $PASSCODE_USERNAME
fi
