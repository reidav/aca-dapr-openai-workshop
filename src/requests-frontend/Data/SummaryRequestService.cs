namespace Frontend.Data;

using System.Text.Json;
using Dapr.Client;

public class SummaryRequestService
{
    private readonly DaprClient _daprClient;
    private readonly AppSettings _settings;

    private readonly ILogger<SummaryRequestService> _logger;

    public SummaryRequestService(DaprClient daprClient, AppSettings settingsService, ILogger<SummaryRequestService> Logger)
    {
        this._daprClient = daprClient;
        this._settings = settingsService;
        this._logger = Logger;
    }

    public async Task AddSummaryRequestAsync(NewSummaryRequestPayload newSummaryRequest)
    {
        CancellationTokenSource source = new CancellationTokenSource();
        CancellationToken cancellationToken = source.Token;

        await this._daprClient.PublishEventAsync<NewSummaryRequestPayload>(
            _settings.PubRequestName,
            _settings.PubRequestTopic,
            newSummaryRequest,
            cancellationToken
        );
    }

    public async Task<SummaryRequest[]> GetSummaryRequestsAsync()
    {
        HttpRequestMessage? response = this._daprClient.CreateInvokeMethodRequest(
            HttpMethod.Get,
            _settings.requestsApiAppId,
            _settings.requestsApiEndpoint
        );
        return await this._daprClient.InvokeMethodAsync<SummaryRequest[]>(response);
    }
}
