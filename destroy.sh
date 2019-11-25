#!/bin/bash

S3_BUCKET="expert-nirav-terraform-statebucket-eu-west-1"
DYNAMO_DB="terraform_statelock"

echo -e "\n====================================="
echo "-> Destroying DevOps Setup"
echo "====================================="

cd terraform; \
    terraform init --backend-config="dynamodb_table=$DYNAMO_DB" --backend-config="bucket=$S3_BUCKET"; \
    terraform destroy -auto-approve
