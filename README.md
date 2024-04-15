# Summarizer using Azure Open AI

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/reidav/aca-dapr-openai-workshop?quickstart=1)

Hands-on-guide : [https://aka.ms/aca-dapr-workshop](https://aka.ms/aca-dapr-workshop)

Welcome to this **Dapr, Azure Container Apps Workshop**. You'll be experimenting with Azure Serverless services in multiple labs to achieve a real world scenario. Don't worry, even if the challenges will increase in difficulty, this is a step by step lab, you will be guided through the whole process.

During this workshop you will have the instructions to complete each steps. It is recommended to search for the answers in provided resources and links before looking at the solutions placed under the 'Toggle solution' panel.

## Prerequisites

Before starting this workshop, be sure you have:

- A dedicated resource group with the the `Owner` role to create and manage the labs' resources and ease the cleanup at the end.
- Azure providers should be registerd on your Azure Subscription if not done yet: `Microsoft.CognitiveServices`, `Microsoft.DocumentDB`, `Microsoft.ContainerRegistry`, `Microsoft.KeyVault`, `Microsoft.ServiceBus`,`Microsoft.Web`
- A ready to use Azure Open AI instance (API Key and API  Endpoint)
- An existing SMTP server (host, port) to be used in the lab.

## Summarizer

**Summarizer** is an application designed to demonstrates how to build a, intelligent cloud native application using Dapr, Containers Apps and Open AI. It is composed of multiple microservices.

![SummarizeArchitecture](docs/assets/images/summarizer-dapr-aca.png)

**Summarizer Blazor App (Front-end)** : A Blazor WebAssembly application that allows to browse all summaries and eventually queue new links to be summarized.

**Requests API (Python)** : FastAPI leveraging Dapr state management to store / get all requests of summaries. It allows to track and reuse previous summaries eventually generated. When a new completed request is created following processing, it sends a email message to the requestor.

**Requests Processor (Python)** : A Python application that allows to process summary requests in queue. If no summary has already being provided, it will prompt Azure Open AI to get a new summary. In any case, requests will be tracked using the requests API at the end of the process.

