#!/usr/bin/env bash
set -e

export RESOURCE_GROUP=rg-gptsum-swn
export TIMESTAMP=$(date +%s)
export REGISTRY=<REGISTRY>.azurecr.io

# Could be used if you want to set the registry name without deploying the infra
# (just commenting out the infra deployment below, and update this value)
echo "Container Registry: $REGISTRY"

# Login to Azure
echo "Logging in to Azure Container Registry..."
az acr login --name $REGISTRY

# Build and push images
echo "Building and pushing images..."
export TIMESTAMP=$(date +%s)
echo $TIMESTAMP

docker build -t $REGISTRY/summarizer/requests-api:$TIMESTAMP ./src/requests-api
docker build -t $REGISTRY/summarizer/requests-processor:$TIMESTAMP ./src/requests-processor
docker build -t $REGISTRY/summarizer/requests-frontend:$TIMESTAMP  ./src/requests-frontend
docker push $REGISTRY/summarizer/requests-api:$TIMESTAMP
docker push $REGISTRY/summarizer/requests-processor:$TIMESTAMP
docker push $REGISTRY/summarizer/requests-frontend:$TIMESTAMP

# Deploy Container Apps
echo "Deploying Container Apps..."
AZ_CAENV_DEPLOYMENT=$( az deployment group create \
                        --resource-group $RESOURCE_GROUP \
                        --template-file ./infra/apps.bicep \
                        --parameters ./infra/parameters.jsonc \
                        --parameters imageTag=$TIMESTAMP)