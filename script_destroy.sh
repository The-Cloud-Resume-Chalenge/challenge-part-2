#!/bin/bash

# Navigate to your Terraform directory if needed
cd ./static_website

# Run terraform apply
terraform destroy -auto-approve



# Check if terraform apply was successful
if [ $? -eq 0 ]; then
    echo "Terraform destroying infrastructure. "
else
    echo "Terraform apply failed. Aborting script."
    exit 1
fi



