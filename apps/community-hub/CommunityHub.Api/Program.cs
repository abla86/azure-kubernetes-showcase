using Azure.Identity;
using Azure.Monitor.OpenTelemetry.Exporter;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

var builder = WebApplication.CreateBuilder(args);

const string serviceName = "community-hub";
var credential = new DefaultAzureCredential();

builder.Services
    .AddOpenTelemetry()
    .ConfigureResource(resource => resource.AddService(serviceName))
    .UseAzureMonitorExporter(options =>
    {
        options.Credential = credential;
    })

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
