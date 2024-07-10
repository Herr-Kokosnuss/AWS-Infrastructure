#To initialize Terraform for the dev workspace, run: ./init_backend.sh dev
#To initialize Terraform for the prod workspace, run: ./init_backend.sh prod

#!/bin/bash

# Check if an argument is provided
if [ $# -eq 0 ]; then
  echo "No workspace specified. Usage: $0 [dev|prod]"
  exit 1
fi

# Set workspace based on the first argument
workspace=$1

# Validate workspace
if [ "$workspace" != "dev" ] && [ "$workspace" != "prod" ]; then
  echo "Invalid workspace specified. Use 'dev' or 'prod'."
  exit 1
fi


# Set the workspace name
WORKSPACE_NAME=$1 # Change this to your workspace name

# Use the workspace name to set the key dynamically
KEY="${WORKSPACE_NAME}/terraform.tfstate"

# Now, run terraform init to initialize the backend with the dynamic key

terraform init \
  -backend-config="bucket=terraform-state-8520-${workspace}" \
  -backend-config="dynamodb_table=terraform-state-locks-${workspace}"
