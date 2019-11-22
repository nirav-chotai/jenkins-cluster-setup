#!/bin/bash

S3_BUCKET="expert-nirav-terraform-statebucket-eu-west-1"
DYNAMO_DB="terraform_statelock"

echo -e "\n====================================="
echo "-> Installing/verifying Terraform..."
echo "====================================="
terraform --version 2>&1 >/dev/null
TERRAFORM_IS_INSTALLED=$?
if [ $TERRAFORM_IS_INSTALLED -eq 0 ]; then
	echo "Terraform is installed."
else
	echo "Terraform is not installed. Installing Terraform..."
	sudo wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
	sudo unzip terraform_0.11.7_linux_amd64.zip
	sudo mv terraform /usr/local/bin/
fi
TERRAFORM_VERSION="$(terraform --version)"
echo "Terraform Version -> "$TERRAFORM_VERSION

echo -e "\n====================================="
echo "-> S3 Bucket for Remote State"
echo "====================================="
if aws s3 ls "s3://$S3_BUCKET" 2>&1 | grep -q 'NoSuchBucket'; then
    aws s3 mb s3://$S3_BUCKET --region eu-west-1
else
    echo "bucket $S3_BUCKET already exists"
fi

echo -e "\n====================================="
echo "-> DynamoDB for Remote State Locking"
echo "====================================="
if aws dynamodb create-table \
    --table-name $DYNAMO_DB \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 2>&1 | grep -q 'ResourceInUseException'; then
    echo "Table $DYNAMO_DB already exists"
else
    echo "Table $DYNAMO_DB created"
fi

echo -e "\n====================================="
echo "-> Starting DevOps Setup"
echo "====================================="
# Terraform initialization and applying plan to build AWS infrastructure
# For Intermittent error using s3 state
# Refer https://github.com/terraform-providers/terraform-provider-aws/issues/4709
cd terraform; \
    terraform init --backend-config="dynamodb_table=$DYNAMO_DB" --backend-config="bucket=$S3_BUCKET"; \
    terraform apply
