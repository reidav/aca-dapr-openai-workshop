import json, logging, os

from fastapi import Body, FastAPI, Response
from fastapi.responses import HTMLResponse
from dapr.clients import DaprClient
from dapr.ext.fastapi import DaprApp

from settings import Settings
from request_handler import SummarizeRequestHandler
from request_entities import SummarizeRequestCloudEvent

logging.basicConfig(level=logging.INFO)

app = FastAPI()
dapr_app = DaprApp(app)
dapr_client = DaprClient()

@dapr_app.subscribe(pubsub='summarizer-pubsub', topic='link-to-summarize')
async def link_to_summarize(event : SummarizeRequestCloudEvent):
    try:
        logging.info("New link to summarize event was triggered.")
        logging.info(event)

        settings = Settings(dapr_client)
        req_handle = SummarizeRequestHandler(dapr_client, settings, event)
        await req_handle.run()
    except Exception as e:
        logging.error("Url Received to summarize but an issue occured.")
        logging.error(e)

@app.get('/', response_class = HTMLResponse)
async def read_items():
    return """
    <html>
        <head>
            <title>Requests Processor API</title>
        </head>
        <body>
            <h1>Requests Processor API Ready !</h1>
        </body>
    </html>
    """
