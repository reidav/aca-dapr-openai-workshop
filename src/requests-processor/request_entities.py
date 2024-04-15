import json
import logging
from pydantic import BaseModel
    
class SummarizeRequestEventData(BaseModel):
    url : str
    email : str

class SummarizeRequestCloudEvent(BaseModel):
    data: SummarizeRequestEventData
    datacontenttype: str
    id: str
    pubsubname: str
    source: str
    specversion: str
    time: str
    topic: str
    traceid: str
    traceparent: str
    tracestate: str
    type: str

class SummarizeRequest(dict):       

    def __init__(self, id, url, summary, email, timestamp : float):
        dict.__init__(self, id=id, url=url, summary=summary, email=email, timestamp=timestamp)

    def get_id(self):
        return self.get("id")

    def get_url(self):
        return self.get("url")

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
            request["summary"],
            request["email"],
            request["timestamp"]
        )
