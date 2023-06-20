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
        // TODO : Add the new summary request to the requests API
        await Task.CompletedTask;
    }

    public async Task<SummaryRequest[]> GetSummaryRequestsAsync()
    {
        // TODO : Get all the summary request
        return await Task.FromResult(Array.Empty<SummaryRequest>());
    }
}
