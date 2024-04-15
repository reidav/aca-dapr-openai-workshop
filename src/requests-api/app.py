import hashlib
import uuid
import json
import logging
import time

from fastapi import FastAPI, Response, status
from fastapi.responses import HTMLResponse
from dapr.clients import DaprClient
from dapr.ext.fastapi import DaprApp

from settings import Settings
from request_state import SummarizeRequestState
from request_entities import NewSummarizeRequest, SearchSummarizeRequest, SummarizeRequest

logging.basicConfig(level=logging.INFO)

app = FastAPI()
dapr_app = DaprApp(app)
dapr_client = DaprClient()

# Retrieve all requests
@app.get('/requests')
async def get_requests():
    try:
        settings = Settings(dapr_client)
        requests = SummarizeRequestState(dapr_client, settings).find_all()
        return Response(content=json.dumps(requests), media_type="application/json")
    except Exception as e:
        logging.error(f'Error: {e}')
        return Response(content=json.dumps([]), media_type="application/json", status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

# Retrieve request by url
@app.post('/search-requests-by-url')
async def search_request_by_url(search: SearchSummarizeRequest):
    try:
        settings=Settings(dapr_client)
        state_provider=SummarizeRequestState(dapr_client, settings)
        
        url_hashed = hashlib.sha256(search.url.encode()).hexdigest()
        logging.info(f"Searching request for url: {search.url} hashed: {url_hashed}")
        request=state_provider.try_find_by_url_hashed(url_hashed)

        if request is None:
            logging.info(f"Request not found for url: {search.url}")
            return Response(content = None, status_code = status.HTTP_204_NO_CONTENT)
        else:
            logging.info(f"Request found for url: {search.url}")
            return Response(content = json.dumps(request), status_code= status.HTTP_200_OK, media_type = "application/json")
    except Exception as e:
        logging.error(f'Error: {e}')
        return Response(content = None, status_code = status.HTTP_500_INTERNAL_SERVER_ERROR)

@app.post('/requests', status_code = status.HTTP_201_CREATED)
async def create_request(new_request: NewSummarizeRequest):
    try:
        settings=Settings(dapr_client)
        state_provider=SummarizeRequestState(dapr_client, settings)

        request=SummarizeRequest(
            uuid.uuid4().hex,
            new_request.url,
            hashlib.sha256(new_request.url.encode()).hexdigest(),
            new_request.summary,
            new_request.email,
            time.time()
        )

        logging.info(
            f"Saving new request in state and send email to requestor")
        new_request=state_provider.upsert(request)

        return Response(content = json.dumps(new_request), media_type = "application/json")
    except Exception as e:
        logging.error(f'Error: {e}')
        return Response(content = json.dumps([]), media_type = "application/json")

@app.get('/', response_class = HTMLResponse)
async def read_items():
    return """
    <html>
        <head>
            <title>Requests API</title>
        </head>
        <body>
            <h1>Requests API Ready !</h1>
        </body>
    </html>
    """
