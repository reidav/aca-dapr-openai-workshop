using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web;
using Frontend.Data;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

// Add environment variables
builder.Configuration.AddEnvironmentVariables();

// Add services to the container.
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();
builder.Services.AddSingleton<SummaryRequestService>();
builder.Services.AddSingleton<AppSettings>();
builder.Services.AddDaprClient(client =>
{
    client.UseJsonSerializationOptions(new JsonSerializerOptions()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        PropertyNameCaseInsensitive = true
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
}


app.UseStaticFiles();

app.UseRouting();

app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();
