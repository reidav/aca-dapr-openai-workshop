# Deploy to Azure with the CLI

### Deploy to Azure with the CLI

1. Ensure you have access to an Azure subscription and the Azure CLI installed
   ```bash
   az login
   az upgrade
   az account set --subscription "My Subscription"
   ```
1. Ensure you have access to an Azure subscription and the Azure CLI installed
   ```bash
   az extension add --name containerapp --upgrade
   ```
1. Clone this repository
   ```bash
   git clone https://github.com/reidav/aca-dapr-openai-workshop.git
   cd aca-dapr-openai-workshop
   ```
1. Deploy the infrastructure
   ```bash
   az deployment group create --resource-group myrg --template-file ./deploy/containerapps/main.bicep --parameters ./deploy/containerapps/main.parameters.jsonc
   ```
1. Log into Azure Container Registry
   You can get your registry name from your resource group in the Azure Portal
   ```bash
   az acr login --name myacr crdevweutemp00
   ```
1. Build and push containers (from the root of the repository)
   ```bash
   docker build -t myacr.azurecr.io/backend:latest ./src/backend
   docker build -t myacr.azurecr.io/frontend:latest ./src/frontend
   docker build -t myacr.azurecr.io/job:latest ./src/job
   docker push myacr.azurecr.io/backend:latest
   docker push myacr.azurecr.io/frontend:latest
   docker push myacr.azurecr.io/job:latest
   ```
1. Deploy the application
   ```bash
   az deployment group deployment create --resource-group myrg --template-file ./iac/app.json
   ```
1. Get your frontend URL
   ```bash
   kubectl get svc
   ```
1. Navigate to your frontend URL