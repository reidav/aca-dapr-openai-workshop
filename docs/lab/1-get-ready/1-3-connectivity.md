---
title: Setup Connectivity
parent: Get Ready
has_children: false
permalink: /lab1/set-secrets
nav_order: 3
---

# Setup Connectivity

## Connect using Azure CLI

1. Open a terminal and connect to Azure CLI using the following command:

```bash
az login --use-device-code
```

2. Open the page https://microsoft.com/devicelogin and enter the code displayed in the terminal.

3. Login with your Azure credentials.

4. Validate that you are connected to the right subscription using the following command:

```bash
az account show
```

## Setup secrets

Actual repositery uses secrets files (ignored by gi)t to prevent secrets being pushed to the repository. We will need to reuse the sample secret files provided, duplicating and updating them with our own secrets.

1. Create a new file `/dapr/summarizer-secrets.json` based on the content of the file  `/dapr/summarizer-secrets-sample.json`. This file will be used by Dapr to inject secrets into the application. Feel free to fill-in the values with your own secrets.

<details markdown="block">
  <summary>
    Toggle solution
  </summary>

```json
{
  "OPENAI-API-KEY": "",
  "OPENAI-API-ENDPOINT": "",
  "SMTP-HOST": "",
  "SMTP-PORT": ""
}
```
</details>

1. Create a new file `/deploy/containerapps/parameters.jsonc` based on the content of the file `/deploy/containerapps/parameters-sample.jsonc`. This file will be used by Bicep to schedule Azure deployment. Pick and choose any workload name, and fill-in the other values with your own secrets.

<details markdown="block">
  <summary>
    Toggle solution
  </summary>

```jsonc
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      // The name of the workload that is being deployed. Up to 10 characters long. This wil be used as part of the naming convention (i.e. as defined here: https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) 
      "workloadName": {
        "value": "<Workload Name>"
      },
      //The name of the environment (e.g. "dev", "test", "prod", "preprod", "staging", "uat", "dr", "qa"). Up to 8 characters long.
      "environment": {
        "value": "dev"
      },
      "uniqueId": {
          "value": "00"
      },
      "openAiApiKey": {
        "value": "<Open AI Key>"
      },
      "openAiApiEndpoint": {
        "value": "<Open API Endpoint>"
      },
      "smtpHost": {
        "value": "<SMTP Host>"
      },
      "smtpPort": {
        "value": 1025
      }
    }
  }
```
</details>