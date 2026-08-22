using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using Serilog;

var builder = WebApplication.CreateBuilder(args);

builder.Host.UseSerilog((context, configuration) =>
{
    configuration
        .Enrich.FromLogContext()
        .WriteTo.Console();
});

builder.Services
    .AddOpenTelemetry()
    .ConfigureResource(resource =>
        resource.AddService("azure-kubernetes-showcase"))
    .WithTracing(tracing =>
    {
        tracing
            .AddAspNetCoreInstrumentation()
            .AddHttpClientInstrumentation();
    })
    .WithMetrics(metrics =>
    {
        metrics
            .AddAspNetCoreInstrumentation()
            .AddRuntimeInstrumentation();
    });

builder.Services.AddHealthChecks();

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy
            .AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

var app = builder.Build();

app.UseSerilogRequestLogging();
app.UseCors();

app.MapHealthChecks("/health");

app.MapGet("/api/health", () =>
    Results.Ok(new
    {
        status = "healthy",
        timestamp = DateTimeOffset.UtcNow
    }));

app.MapGet("/api/info", () =>
    Results.Ok(new
    {
        application = "Azure Kubernetes Showcase",
        version = "1.0.0",
        runtime = ".NET 10",
        environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")
                       ?? "Production"
    }));

app.MapGet("/api/metrics", () =>
    Results.Ok(new
    {
        status = "operational",
        uptime = Environment.TickCount64
    }));

app.MapGet("/api/events", () =>
    Results.Ok(new[]
    {
        new
        {
            type = "deployment",
            message = "Application running",
            timestamp = DateTimeOffset.UtcNow
        }
    }));

app.Run();

public partial class Program;
