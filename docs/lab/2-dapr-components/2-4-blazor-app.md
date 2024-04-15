---
title: Blazor App
parent: Implement Dapr Components
has_children: false
permalink: /lab2/blazor-app
nav_order: 3
---

# Blazor App

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

## Add Blazor App to `dapr.yaml`

As we will be having many dapr applications, let's leverage the [multi-run](https://docs.dapr.io/developing-applications/local-development/multi-app-dapr-run/) feature of Dapr to run all the applications at once. So let's add Blazor App to the `dapr.yaml` file.

* Open the `dapr.yaml` file in the `/` folder and add a new node for the application including the environment variables.

<details markdown="block">
  <summary>
    Toggle solution
  </summary>

```yaml
- appID: summarizer-frontend
  appDirPath: ./src/frontend/
  appPort: 11000
  command: ["dotnet", "run"]
  env:
    PUBSUB_REQUESTS_NAME: "summarizer-pubsub"
    PUBSUB_REQUESTS_TOPIC: "link-to-summarize"
    REQUESTS_API_APP_ID: "summarizer-requests-api"
    REQUESTS_API_ENDPOINT: "requests"
    DOTNET_URLS: "http://*:11000"
```
</details>

> Note: The `appID` is used to identify the application in the Dapr runtime. The `appDirPath` is the path to the application folder. The `appPort` is the port used by the application. The `command` is the command used to start the application. The `env` is the environment variables used by the application.

## Create Pub / Sub yaml

From the previous definition of the environment variables of our application, we can see that we will be using a pub/sub dapr component. Let's create the yaml file for the pub/sub component.

* Create a new file named `summarizer-pubsub.yaml` in the `/dapr/local/components` folder using redis as the pub/sub component.

<details markdown="block">
  <summary>
    Toggle solution
  </summary>

```yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: summarizer-pubsub
spec:
  type: pubsub.redis
  version: v1
  metadata:
  - name: redisHost
    value: localhost:6379
  - name: redisPassword
    value: ""
```
</details>

> Note: The `name` is the name of the component. The `type` is the type of the component. The `version` is the version of the component. The `metadata` is the configuration of the component. We also added a query index to the state store to be able to query the state store by url. url_hashed is the hashed version of the url to ease the search query and avoid any special characters issues.

## Blazor App Overview

1. Open the `SummaryRequestService.cs` file in the `/src/Data/SummaryRequestService` folder, and notice the different methods being used as en entry point to manage external communication with both Request Api and Pub/Sub

```csharp	
// Publish a new request to the pub/sub component
public async Task AddSummaryRequestAsync(NewSummaryRequestPayload newSummaryRequest) { }

// Get all the requests from the request api
public async Task<SummaryRequest[]> GetSummaryRequestsAsync() {}
```
    
## Implementing pub/sub and Http Invocation methods.

1. Open the `SummaryRequestService.cs` file in the `/src/frontend` folder.

2.  Fill the `GetSummaryRequestsAsync` method to get all the requests from the request api. The method should return a list of `Request` objects.

<details markdown="block">
  <summary>
    Toggle solution
  </summary>

```csharp	
public async Task<SummaryRequest[]> GetSummaryRequestsAsync()
{
    HttpRequestMessage? response = this._daprClient.CreateInvokeMethodRequest(
        HttpMethod.Get,
        _settings.requestsApiAppId,
        _settings.requestsApiEndpoint
    );
    return await this._daprClient.InvokeMethodAsync<SummaryRequest[]>(response);
}
```
</details>

3.   Fill the `AddSummaryRequestAsync` method to publish a new request to the pub/sub component.

<details markdown="block">
  <summary>
    Toggle solution
  </summary>

  ```csharp	
  public async Task AddSummaryRequestAsync(NewSummaryRequestPayload newSummaryRequest)
  {
    CancellationTokenSource source = new CancellationTokenSource();
    CancellationToken cancellationToken = source.Token;
    await this._daprClient.PublishEventAsync<NewSummaryRequestPayload>(
        _settings.PubRequestName,
        _settings.PubRequestTopic,
        newSummaryRequest,
        cancellationToken
      );
  }
  ```
</details>

## Validate that the request is sent to Redis

1. Execute dapr run multi run command to start the application

```bash
  dapr run -f .
``` 
2. Open a the blazor application, create a new request using any email and link

3. Check that the request is stored in redis

```bash	
redis-cli
> keys * # See all keys
```