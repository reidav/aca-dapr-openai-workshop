import logging
import os
from retry import retry

class Settings:
    def __init__(self, dapr_client):
        self.dapr_client = dapr_client

        # Dapr settings
        self.secret_store_name = self.__get_environment_variable("SECRET_STORE_NAME")
        self.pubsub_requests_name = self.__get_environment_variable("PUBSUB_REQUESTS_NAME")
        self.pubsub_requests_topic = self.__get_environment_variable("PUBSUB_REQUESTS_TOPIC")

        # Requests API Backend settings
        self.requests_api_app_id = self.__get_environment_variable("REQUESTS_API_APP_ID")
        self.requests_api_search_endpoint = self.__get_environment_variable("REQUESTS_API_SEARCH_ENDPOINT")
        self.requests_api_create_endpoint = self.__get_environment_variable("REQUESTS_API_CREATE_ENDPOINT")

        # INFO : ONLY FOR DEBUG PURPOSE
        self.__show_secrets()

        # OpenAI settings
        self.openai_apiversion = self.__get_environment_variable("OPENAI_API_VERSION")
        self.openai_deploymentname = self.__get_environment_variable("OPENAI_API_DEPLOYMENT_NAME")
        self.openai_apikey = self.__get_secret("OPENAI-API-KEY")
        self.openai_endpoint = self.__get_secret("OPENAI-API-ENDPOINT")

        logging.info(f"""
<environment-variables> 
    secret_store_name:{self.secret_store_name}
    pubsub_requests_name:{self.pubsub_requests_name}
    pubsub_requests_topic:{self.pubsub_requests_topic}
    requests_api_app_id:{self.requests_api_app_id}
    requests_api_create_endpoint:{self.requests_api_create_endpoint}
    requests_api_search_endpoint:{self.requests_api_search_endpoint}
    open_api_version:{self.openai_apiversion}
    open_api_deployment_name:{self.openai_deploymentname}
</environment-variables>
<secrets> 
    ONLY FOR DEMO PURPOSE
    open_api_key:{self.openai_apikey}
    open_api_endpoint:{self.openai_endpoint}
</secrets>
    """)

    @retry(delay=1, backoff=2, max_delay=30)
    def __show_secrets(self):
        try:
            secret = self.dapr_client.get_bulk_secret(store_name=self.secret_store_name)
            logging.info('Result for bulk secret: ')
            logging.info(sorted(secret.secrets.items()))
        except Exception as e:
            raise e

    @retry(delay=1, backoff=2, max_delay=30)
    def __get_secret(self, secret_name):
        try:
            logging.log(logging.INFO, f"Getting secret {secret_name} from secret store {self.secret_store_name} ...")
            secret = self.dapr_client.get_secret(
                store_name=self.secret_store_name,
                key=secret_name
            )
            return secret.secret[secret_name]
        except Exception as e:
            raise e
    
    def __get_environment_variable(self, variable_name, mandatory=True):
        variable = os.environ.get(variable_name)
        if not variable and mandatory:
            raise Exception(f"Environment variable {variable_name} is not set")
        return variable