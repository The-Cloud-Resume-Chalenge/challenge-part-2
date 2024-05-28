#!/bin/bash
CONFIG_FILE="./config/config.json" # Path to your config.json file

# Function to update JSON values
update_json() {
    key="$1"
    value="$2"
    jq --arg key "$key" --arg val "$value" '(.[$key]) = $val' $CONFIG_FILE > temp.$$.json && mv temp.$$.json $CONFIG_FILE
}

# Function to update use_aws_profile based on if the user provided a profile or access key
update_use_aws_profile() {
    if [ -n "$1" ]; then
        update_json "use_aws_profile" "true"
    else
        update_json "use_aws_profile" "false"
    fi
}

# Initialize the starting configuration
cp ./config/config_default.json $CONFIG_FILE 

# Mandatory variables
declare -A variables=(
    ["region_master"]="Type the region"
)

# Optional variables
declare -A optional_variables=(
    ["endpoint"]="API Endpoint"
    ["basic_dynamodb_table"]="Basic DynamoDB Table"
    ["function_name"]="Lambda Function Name"
    ["runtime"]="Lambda Runtime"
)

# Prompt the user for the AWS profile
echo "To use an AWS profile, enter the profile name                      (or type 'none' to specify Access Keys instead):"
read aws_profile

if [[ $aws_profile != "none" ]]; then
    # The user chose to use an AWS profile
    
    # Check if the variable is empty
    if [ -z "$aws_profile" ]; then
        aws_profile="default"
    fi
    update_json "profile" "$aws_profile"
    update_use_aws_profile "profile" # Set use_aws_profile to true
    echo "AWS Profile updated to $aws_profile."
else
    # The user chose to use AWS Access Keys
    echo "AWS Access Key ID:"
    read aws_access_key_id

    echo "AWS Secret Access Key:"
    read -s aws_secret_access_key
    
    # Update keys in the configuration
    if [[ -n $aws_access_key_id ]] && [[ -n $aws_secret_access_key ]]; then
        update_json "aws_access_key_id" "$aws_access_key_id"
        update_json "aws_secret_access_key" "$aws_secret_access_key"
        update_use_aws_profile "" # Set use_aws_profile to no as keys were provided
        update_json "profile" "default"
        echo "AWS access keys updated."
    else
        echo "Invalid input for AWS access keys. Exiting script."
        exit 1
    fi
fi


# Update remaining mandatory variables
for key in "${!variables[@]}"
do
    if [[ ${variables[$key]} ]]; then
        current_value=$(jq -r ".$key" $CONFIG_FILE)
        echo "${variables[$key]} (Current: $current_value):"
        read new_value
        if [[ -n $new_value ]]; then
            update_json "$key" "$new_value"
            echo "$key updated to $new_value."
        fi
    fi
done


echo "Do you want to modify optional parameters? This is not critical to the process (yes/no):"
read modify_optional

if [[ "$modify_optional" == "yes" ]]; then
    for key in "${!optional_variables[@]}"
    do
        current_value=$(jq -r ".$key" $CONFIG_FILE)
        echo "${optional_variables[$key]} (Current: $current_value):"
        read new_value
        if [ ! -z "$new_value" ]; then
            # Ensure new values are properly escaped as JSON strings
            update_json "$key" "$new_value"
            echo "$key updated to $new_value."
        fi
    done
fi

echo "Configuration update complete."