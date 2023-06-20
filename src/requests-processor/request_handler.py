import json
import logging
import openai

from dapr.clients import DaprClient
from settings import Settings
from request_entities import SummarizeRequestCloudEvent

class SummarizeRequestHandler:

    def __init__(self, dapr_client: DaprClient, settings: Settings, event: SummarizeRequestCloudEvent):
        self.dapr_client = dapr_client
        self.settings = settings
        self.event = event

    async def run(self):
        # Add the logic here to process the request
        pass

    async def __try_find_by_url(self, url):
        resp = await self.dapr_client.invoke_method_async(
            self.settings.requests_api_app_id,
            self.settings.requests_api_search_endpoint,
            json.dumps({'url': self.event.data.url}),
            http_verb="POST")
        return json.loads(resp.data.decode('utf-8')) if resp.status_code == 200 else None

    async def __get_summary(self, url):
        openai.api_key = self.settings.api_key
        openai.api_base = self.settings.open_api_endpoint
        openai.api_type = "azure"
        openai.api_version = self.settings.open_api_version

        try:
            response = openai.Completion.create(
                engine=self.settings.open_api_deployment_name,
                prompt=f"Summarize the article {url} in english in less than two paragraphs without adding new information. When the summary seems too short to make at least one paragraph, answer that you can't summarize a text that is too short",
                temperature=0.9,
                max_tokens=200,
                top_p=1,
                frequency_penalty=0,
                presence_penalty=0.6
            )
            logging.info(response)
            return response['choices'][0]['text']

        except Exception as e:
            logging.error(e)
            return "Unable to summarize this article."
