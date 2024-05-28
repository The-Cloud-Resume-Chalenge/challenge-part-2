#!/bin/bash

# Path to the JSON config file
CONFIG_JSON="./config/config.json"

# Path to the terraform.tfvars file to create
TFVARS_FILE="./static_website/terraform.tfvars"

# Clear/Create the terraform.tfvars file
echo "" > $TFVARS_FILE

# Read key-value pairs from JSON and append to terraform.tfvars
jq -r 'to_entries | .[] | (.key | gsub("-"; "_")) + " = " + (if .value | type == "array" then "[" + ( .value | map(if type == "string" then "\"" + . + "\"" else tostring end) | join(", ") ) + "]" else "\"" + (.value | tostring) + "\"" end)' $CONFIG_JSON >> $TFVARS_FILE