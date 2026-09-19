using Azure.Identity;
using Azure.Monitor.OpenTelemetry.Exporter;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

var builder = WebApplication.CreateBuilder(args);

const string serviceName = "care-portal";
var openTelemetry = builder.Services
    .AddOpenTelemetry()
    .ConfigureResource(resource => resource.AddService(serviceName));

var azureMonitorConnectionString = builder.Configuration["APPLICATIONINSIGHTS_CONNECTION_STRING"];
if (!string.IsNullOrWhiteSpace(azureMonitorConnectionString))
{
    var credential = new DefaultAzureCredential();
    openTelemetry.UseAzureMonitorExporter(options =>
    {
        options.ConnectionString = azureMonitorConnectionString;
        options.Credential = credential;
    });
}

builder.Services.AddControllers();
builder.Services.AddHealthChecks();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();
app.MapControllers();
app.MapHealthChecks("/health");

app.Run();

public partial class Program;
