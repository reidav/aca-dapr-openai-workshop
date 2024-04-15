namespace Frontend.Data;

public class AppSettings
{
    public readonly string requestsApiAppId;
    public readonly string requestsApiEndpoint;
    public readonly string PubRequestName;
    public readonly string PubRequestTopic;

    public AppSettings()
    {
        this.PubRequestName = GetEnvironmentVariable("PUBSUB_REQUESTS_NAME");
        this.PubRequestTopic = GetEnvironmentVariable("PUBSUB_REQUESTS_TOPIC");
        this.requestsApiAppId = GetEnvironmentVariable("REQUESTS_API_APP_ID");
        this.requestsApiEndpoint = GetEnvironmentVariable("REQUESTS_API_ENDPOINT");
    }

    public string GetEnvironmentVariable(string name, bool mandatory = true)
    {
        var value = Environment.GetEnvironmentVariable(name);
        if (mandatory && string.IsNullOrEmpty(value))
        {
            throw new Exception($"Environment variable {name} is not set.");
        }
        return string.IsNullOrEmpty(value) ? string.Empty : value;
    }
}
