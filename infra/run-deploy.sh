#!/usr/bin/env bash
set -e

export RESOURCE_GROUP=rg-devoxx-swn

az group create --name $RESOURCE_GROUP --location switzerlandnorth

# Deploy Container Apps Environment and its prerequisites
echo "Deploying Container Apps Environment and its prerequisites to $RESOURCE_GROUP..."
AZ_CAENV_DEPLOYMENT=$(az deployment group create \
                        --resource-group $RESOURCE_GROUP \
                        --template-file ./infra.bicep \
                        --parameters ./parameters.jsonc)

# echo "Retrieving Container Registry..."
REGISTRY=$(echo $AZ_CAENV_DEPLOYMENT | grep -oE -m 1 '/registries/([^/]+)' | tail -n +2 | cut -d'/' -f3).azurecr.io
echo "Container Registry: $REGISTRY"