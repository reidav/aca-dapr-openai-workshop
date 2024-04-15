#!/usr/bin/env bash
set -e

export RESOURCE_GROUP=rg-dev-swn-linksummarizer
export WORKLOAD_NAME=summarizer
export ENVIRONMENT=dev
export UNIQUE_ID=01

# Create Resource Group
# Check the availability of the OpenAI gpt-4, 0613 model in your region:
# https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models#standard-deployment-model-availability
az group create --name $RESOURCE_GROUP --location australiaeast

# Deploy Container Apps Environment and its prerequisites
echo "Deploying Container Apps Environment and its prerequisites to $RESOURCE_GROUP..."
AZ_CAENV_DEPLOYMENT=$(az deployment group create \
                        --resource-group $RESOURCE_GROUP \
                        --template-file ./infra.bicep \
                        --parameters workloadName=$WORKLOAD_NAME \
                        --parameters environment=$ENVIRONMENT \
                        --parameters uniqueId=$UNIQUE_ID)

# echo "Retrieving Container Registry..."
REGISTRY=""
REGISTRY=$(echo $AZ_CAENV_DEPLOYMENT | grep -oE -m 1 '/registries/([^/]+)' | tail -n +2 | cut -d'/' -f3).azurecr.io
echo "Container Registry: $REGISTRY"

# Login to Azure
echo "Logging in to Azure Container Registry..."
az acr login --name $REGISTRY

# Build and push images
echo "Building and pushing images..."
export TIMESTAMP=$(date +%s)
echo $TIMESTAMP

docker build -t $REGISTRY/summarizer/requests-api:$TIMESTAMP ../src/requests-api
docker build -t $REGISTRY/summarizer/requests-processor:$TIMESTAMP ../src/requests-processor
docker build -t $REGISTRY/summarizer/requests-frontend:$TIMESTAMP  ../src/requests-frontend
docker push $REGISTRY/summarizer/requests-api:$TIMESTAMP
docker push $REGISTRY/summarizer/requests-processor:$TIMESTAMP
docker push $REGISTRY/summarizer/requests-frontend:$TIMESTAMP

# Deploy Container Apps
echo "Deploying Container Apps..."
AZ_CAENV_DEPLOYMENT=$( az deployment group create \
                        --resource-group $RESOURCE_GROUP \
                        --template-file ./apps.bicep \
                        --parameters workloadName=$WORKLOAD_NAME \
                        --parameters environment=$ENVIRONMENT \
                        --parameters uniqueId=$UNIQUE_ID \
                        --parameters imageTag=$TIMESTAMP)