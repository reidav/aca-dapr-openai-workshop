namespace Frontend.Data;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

public record SummaryRequest
{
    [JsonPropertyName("email")]
    [Required]
    [EmailAddress]
    public string? Email { get; set; }

    [JsonPropertyName("url")]
    [Required]
    [Url]
    public string? Url { get; set; }

    [JsonPropertyName("summary")]
    public string? Summary { get; set; }

    [JsonPropertyName("id")]
    public string? Id { get; set; }
}

public record NewSummaryRequestPayload
{
    [JsonPropertyName("email")]
    [Required]
    [EmailAddress]
    public string? Email { get; set; }

    [JsonPropertyName("url")]
    [Required]
    [Url]
    public string? Url { get; set; }
}