import logging
import os
from dapr.clients import DaprClient

class Settings:
    def __init__(self, dapr_client : DaprClient):
        self.dapr_client = dapr_client

        # Dapr settings        
        self.state_store_name = self.__get_environment_variable("STATE_STORE_NAME")
        self.state_store_query_index_name = self.__get_environment_variable("STATE_STORE_QUERY_INDEX_NAME", False)
        self.binding_smtp = self.__get_environment_variable("BINDING_SMTP")

        logging.info(f"""
<environment-variables>
    state_store_name:{self.state_store_name}
    state_store_query_index_name:{self.state_store_query_index_name}
    binding_smtp:{self.binding_smtp}
</environment-variables>""")
       
    def __get_environment_variable(self, variable_name, mandatory=True):
        variable = os.environ.get(variable_name)
        if not variable and mandatory:
            raise Exception(f"Environment variable {variable_name} is not set")
        return variable