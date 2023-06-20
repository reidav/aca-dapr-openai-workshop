import logging
import json
from dapr.clients import DaprClient
from settings import Settings
from request_entities import SummarizeRequest


class SummarizeRequestState:

    def __init__(self, dapr_client: DaprClient, settings: Settings):
        self.dapr_client = dapr_client
        self.settings = settings

    def find_all(self, token: str = None):
        # Add the logic here to get all requests
        return None

    def try_find_by_id(self, id : str):
        return self.__try_filter("id", id)
    
    def try_find_by_url_hashed(self, url_hashed : str):
        return self.__try_filter("url_hashed", url_hashed)
    
    def upsert(self, request: SummarizeRequest):
        try:
            self.dapr_client.save_state(
                self.settings.state_store_name,
                key=request.get_id(),
                value=json.dumps(request),
                state_metadata={"contentType": "application/json"}
            )
            self.__alert_owner(request)
            return self.try_find_by_id(request.get_id())
        except Exception as e:
            logging.error(
                f"Error while trying to upsert {request.get_url()} within the dapr state store")
            logging.error(e)

        return None

    def delete(self, id : str):
        try:
            self.dapr_client.delete_state(
                self.settings.state_store_name, key=id)
        except Exception as e:
            logging.error(
                f"Error while deleting {id} within the dapr state store \n {e}")

    def __try_filter(self, property : str, value : str):
        # Add the logic here to filter by property
        return None
    
    def __query_state(self, query : str):
        requests = []

        states_metadata = {"contentType": "application/json"}

        # Some components requires custom settings (Redis)
        if self.settings.state_store_query_index_name is not None:
            states_metadata["queryIndexName"] = self.settings.state_store_query_index_name

        logging.info(
            f"Querying state store : {self.settings.state_store_name} \
                with query : {query} \
                and metadata : {states_metadata}"
        )

        resp = self.dapr_client.query_state(
            store_name=self.settings.state_store_name,
            query=query,
            states_metadata=states_metadata
        )

        for result in resp.results:
            request = SummarizeRequest.from_bytes(result.value)
            requests.append(request)

        return requests
    
    def __alert_owner(self, request: SummarizeRequest):
        pass