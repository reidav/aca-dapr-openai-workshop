import json
import logging
from pydantic import BaseModel

class SearchSummarizeRequest(BaseModel):
    url : str

class NewSummarizeRequest(BaseModel):
    url : str
    email : str
    summary : str

class SummarizeRequest(dict):       

    def __init__(self, id : str, url : str, url_hashed : str, summary : str, email : str, timestamp : float):
        dict.__init__(self, id=id, url=url, url_hashed=url_hashed, summary=summary, email=email, timestamp=timestamp)

    def get_id(self):
        return self.get("id")

    def get_url(self):
        return self.get("url")
    
    def get_url_hashed(self):
        return self.get("url_hashed")

    def get_summary(self):
        return self.get("summary")

    def get_email(self):
        return self.get("email")

    def get_timestamp(self) -> float:
        return self.get("timestamp")
    
    @staticmethod
    def from_bytes(json_bytes : bytes):
        request = json.loads(json_bytes.decode('utf-8'))
        return SummarizeRequest(
            request["id"],
            request["url"],
            request["url_hashed"],
            request["summary"],
            request["email"],
            request["timestamp"]
        )
