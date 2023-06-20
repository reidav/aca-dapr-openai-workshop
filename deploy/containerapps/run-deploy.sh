#!/usr/bin/env bash
set -e

export RESOURCE_GROUP=rg-acadapr-1

# Could be used if you want to set the registry name without deploying the infra
# (just commenting out the infra deployment below, and update this value)
# export REGISTRY=crdevweutemp00.azurecr.io

# Deploy Container Apps Environment and its prerequisites
echo "Deploying Container Apps Environment and its prerequisites to $RESOURCE_GROUP..."
AZ_CAENV_DEPLOYMENT=$(az deployment group create \
                        --resource-group $RESOURCE_GROUP \
                        --template-file ./infra.bicep \
                        --parameters ./parameters.jsonc)

# echo "Retrieving Container Registry... from previous deployment"
REGISTRY=$(echo $AZ_CAENV_DEPLOYMENT | grep -oE -m 1 '/registries/([^/]+)' | tail -n +2 | cut -d'/' -f3).azurecr.io
echo "Container Registry: $REGISTRY"

# Login to Azure
echo "Logging in to Azure Container Registry..."
az acr login --name $REGISTRY

# Build and push images

# Deploy Container Apps

