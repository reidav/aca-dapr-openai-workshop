import json
import logging

from openai import AzureOpenAI
from dapr.clients import DaprClient
from settings import Settings
from request_entities import SummarizeRequestCloudEvent

class SummarizeRequestHandler:

    def __init__(self, dapr_client: DaprClient, settings: Settings, event: SummarizeRequestCloudEvent):
        self.dapr_client = dapr_client
        self.settings = settings
        self.event = event

    async def run(self):
        logging.debug("Trying to find existing request in state")
        request = await self.__try_find_by_url(self.event.data.url)

        if not (request):
            logging.info(
                f"Azure Open AI requests for {self.event.data.url}")
            summary = await self.__get_summary(self.event.data.url)
        else:
            logging.info(
                f"Get summary from state for {self.event.data.url}")
            summary = request["summary"]

        resp = await self.dapr_client.invoke_method_async(
            self.settings.requests_api_app_id,
            self.settings.requests_api_create_endpoint,
            json.dumps({'url': self.event.data.url, 'email': self.event.data.email, 'summary': summary}),
            http_verb="POST")

    async def __try_find_by_url(self, url):
        resp = await self.dapr_client.invoke_method_async(
            self.settings.requests_api_app_id,
            self.settings.requests_api_search_endpoint,
            json.dumps({'url': self.event.data.url}),
            http_verb="POST")
        return json.loads(resp.data.decode('utf-8')) if resp.status_code == 200 else None

    async def __get_summary(self, url):
        client = AzureOpenAI(
            azure_endpoint = self.settings.openai_endpoint, 
            api_key=self.settings.openai_apikey,
            api_version=self.settings.openai_apiversion
        )

        try:
            response = client.chat.completions.create(
                model=self.settings.openai_deploymentname,
                messages=[
                    {"role": "system", "content": "You are a helpful assistant helping people summarizing articles"},
                    {"role": "user", "content": f"Summarize the article {url} in english in less than two paragraphs without adding new information. When the summary seems too short to make at least one paragraph, answer that you can't summarize a text that is too short"},
                ],
                temperature=0,
                max_tokens=1000
            )
            
            content = response.choices[0].message.content
            logging.info(content)
            return content

        except Exception as e:
            logging.error(e)
            return "Unable to summarize this article."
