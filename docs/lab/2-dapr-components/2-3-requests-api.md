---
title: Requests API
parent: Implement Dapr Components
has_children: false
permalink: /lab2/requests-api
nav_order: 2
---

# Requests API

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>

## Add Request API to `dapr.yaml`

As we will be having many dapr applications, let's leverage the [multi-run](https://docs.dapr.io/developing-applications/local-development/multi-app-dapr-run/) feature of Dapr to run all the applications at once. For now, let's add the request api only to the `dapr.yaml` file.

* Open the `dapr.yaml` file in the `/` folder and add a new node for the application including the environment variables.

<details markdown="block">
  <summary>
    Toggle solution
  </summary>

```yaml
- appID: summarizer-requests-api
  appDirPath: ./src/requests-api/
  appPort: 13000
  command: ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "13000"]
  env:
    STATE_STORE_NAME: "summarizer-statestore"
    STATE_STORE_QUERY_INDEX_NAME: "orgIndx"
    BINDING_SMTP: "summarizer-smtp"
    APP_PORT: 13000
```
</details>

> Note: The `appID` is used to identify the application in the Dapr runtime. The `appDirPath` is the path to the application folder. The `appPort` is the port used by the application. The `command` is the command used to start the application. The `env` is the environment variables used by the application.

## Create State Store yaml

From the previous definition of the environment variables of our application, we can see that we will be using a state store. Let's create the yaml file for the state store.

* Create a new file named `summarizer-statestore.yaml` in the `/dapr/local/components` folder, add a state store component called 'summarizer-statestore' and configure it to use Redis. Query indexes should also be configured to allow for fast retrieval of data (url, url_hashed and id).

<details markdown="block">
  <summary>
    Toggle solution
  </summary>

```yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: summarizer-statestore
spec:
  type: state.redis
  version: v1
  metadata:
  - name: redisHost
    value: localhost:6379
  - name: redisPassword
    value: ""
  - name: queryIndexes
    value: |
      [
        {
          "name": "orgIndx",
          "indexes": [
            {
              "key": "id",
              "type": "TEXT"
            },
            {
              "key": "url",
              "type": "TEXT"
            },
            {
              "key": "url_hashed",
              "type": "TEXT"
            }
          ]
        }
      ] 
```
</details>

> Note: The `name` is the name of the component. The `type` is the type of the component. The `version` is the version of the component. The `metadata` is the configuration of the component. We also added a query index to the state store to be able to query the state store by url. url_hashed is the hashed version of the url to ease the search query and avoid any special characters issues.

## Request API Overview

1. Open the `app.py` file in the `/src/requests-api` folder, and notice the DaprClient object that is used to interact with the Dapr runtime.
    
```python
dapr_client = DaprClient()
```
2. We also have several endpoints defined to manage the requests lifecycle :
    * `@app.get('/requests')` : Get all the requests
    * `@app.post('/search-requests-by-url')` : Search a request with specific link
    * `@app.post('/requests', status_code = status.HTTP_201_CREATED)` : Create a request

## Implementing state and SMTP binding methods

Let's implement the state methods and the SMTP output binding.

1. Open the `request_state.py` file in the `/src/requests-api` folder, managing the state store.

> `def __query_state(self, query : str)` is using the DaprClient object to execute the query to the state store.

2.  Fill the `find_all` method to get all the requests from the state store. The method should return a list of `Request` objects.

<details markdown="block">
  <summary>
    Toggle solution
  </summary>

{% raw %}
```python
def find_all(self, token: str = None):
try:
     # Paging are supported using token
     # see https://docs.dapr.io/developing-applications/building-blocks/state-management/howto-state-query-api/

     token = f", \"token\": \"{token}\"" if token is not None else ""
     query = '''
     {{
         "page": {{
             "limit": 100{0}
         }}
     }}
     '''.format(token)

     return self.__query_state(query)
except Exception as e:
    logging.error(
        f"Error while trying to find all requests within the dapr state store")
    logging.error(e)
    return []
```
{% endraw %}
</details>

3.   Fill the `__try_filter` method to get a request from the state store using a specific property and value. The method should return a `Request` object or None.

<details markdown="block">
  <summary>
    Toggle solution
  </summary>

{% raw %}
```python
def __try_filter(self, property : str, value : str):
    try:
        query = '''
        {{
            "filter": {{
                "EQ": {{ "{0}": "{1}" }}
            }}
        }}
        '''.format(property, value)        
        results = self.__query_state(query)
        return results[0] if len(results) > 0 else None
    except Exception as e:
        logging.error(
            f"Error while trying to find request using {property} and {value} within the dapr state store")
        logging.error(e)    
        return None
```
{% endraw %}
</details>

4.   Fill the `__alert_owner` method to invoke the smtp binding, providing an email contents as a data.None.

<details markdown="block">
  <summary>
    Toggle solution
  </summary>

{% raw %}
```python
def __alert_owner(self, request: SummarizeRequest):
    # Send email to requestor
    email_contents = """
    <html>
        <body>
            <p>Hi,</p>
            <p>Here is the summary for the article you requested:</p>
            <p><a href="{url}">{url}</a></p>
            <p>{summary}</p>
            <p>Thanks for using our service!</p>
        </body>
    </html>        
    """.format(url=request.get_url(), summary=request.get_summary())
    self.dapr_client.invoke_binding(
        binding_name=self.settings.binding_smtp,
        operation='create',
        data=json.dumps(email_contents),
        binding_metadata={
            "emailTo": request.get_email(),
            "subject": f"🎉 New Summary for {request.get_url()}!"
        }
    )
```
{% endraw %}
</details>

## Validate that the request is stored in the state store and email received

1. Execute dapr run multi run command to start the application

    ```bash
    dapr run -f .
    ``` 
2. Open a new terminal and use curl to validate new request creation

3. Check that the request is stored in the state store and email received