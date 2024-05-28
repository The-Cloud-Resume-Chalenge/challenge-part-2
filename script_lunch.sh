#!/bin/bash
CONFIG_FILE="./config/config.json" # Path to your config.json file
VISIT_FILE="./config/first_run.json" # Path to your first_run.json file

# Function to update JSON values
update_visit() {
    key="$1"
    value="$2"
    jq --arg key "$key" --arg val "$value" '(.[$key]) = $val' $VISIT_FILE > temp.$$.json && mv temp.$$.json $VISIT_FILE
}

# Check for first visit
first_visit=$(jq -r '.first_visit' "$VISIT_FILE")

if [[ $first_visit == "true" ]]; then
    echo "Welcome! It looks like it's your first visit. Let's get started."
    echo ""
    # Execute necessary script on first visit
    ./scripts/start.sh # Collecting users' parameters
    
    # Update the first_visit flag in config.json
    update_visit "first_visit" "false"
else
    echo "Welcome back! Skipping initial setup."
fi

./scripts/script_fill_vars.sh
# Directly proceed to applying terraform
cd ./static_website
# Check if .terraform directory exists to determine if terraform init is needed
if [ ! -d ".terraform" ]; then
    echo "Init terraform" 
    terraform init
fi
terraform apply -auto-approve
cd ..

# Check if terraform apply was successful
if [ $? -eq 0 ]; then
    echo "Terraform apply succeeded. You can view your website."
else
    echo "Terraform apply failed. Aborting script."
    exit 1
fi