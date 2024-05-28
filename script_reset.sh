#!/bin/bash
CONFIG_FILE="./config/config.json" # Path to your config.json file
VISIT_FILE="./config/first_run.json" # Path to your first_run.json file



update_visit() {
    key="$1"
    value="$2"
    jq --arg key "$key" --arg val "$value" '(.[$key]) = $val' $VISIT_FILE > temp.$$.json && mv temp.$$.json $VISIT_FILE
}

# Initialize the starting configuration
cp ./config/config_default.json $CONFIG_FILE 

./scripts/script_fill_vars.sh

# Just like  the first visit
update_visit "first_visit" "true"