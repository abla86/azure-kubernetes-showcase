using Azure.Identity;
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

var credential = new DefaultAzureCredential();

builder.Services
    .AddOpenTelemetry()
    .ConfigureResource(resource => resource.AddService("azure-kubernetes-showcase"))
    .UseAzureMonitorExporter(options =>
    {
        options.Credential = credential;
    })
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation())
    .WithMetrics(metrics => metrics
        .AddAspNetCoreInstrumentation()
        .AddRuntimeInstrumentation());

builder.Services.AddHealthChecks();

builder.Services.AddCors(options =>
{
    options.AddPolicy("frontend", policy =>
    {
        policy
            .AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

var app = builder.Build();

app.Use(async (context, next) =>
{
    context.Response.Headers["X-Clacks-Overhead"] = "GNU Terry Pratchett";
    context.Response.Headers["X-Defense-Depth"] = "Zero-Trust-Active";
    await next();
});

app.UseSerilogRequestLogging();
app.UseCors("frontend");

app.MapHealthChecks("/health");

app.MapGet("/api/health", () =>
    Results.Ok(new
    {
        status = "healthy",
        service = "azure-kubernetes-showcase",
        timestamp = DateTimeOffset.UtcNow
    }));

app.MapGet("/api/info", () =>
    Results.Ok(new
    {
        application = "Azure Kubernetes Showcase",
        version = "1.0.0",
        runtime = ".NET 10",
        environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Production"
    }));

app.MapGet("/api/metrics", () =>
    Results.Ok(new
    {
        status = "operational",
        uptimeMilliseconds = Environment.TickCount64
    }));

app.MapGet("/api/events", () =>
    Results.Ok(new[]
    {
        new
        {
            type = "deployment",
            message = "Application running",
            timestamp = DateTimeOffset.UtcNow
        },
        new
        {
            type = "observability",
            message = "Health and telemetry endpoints enabled",
            timestamp = DateTimeOffset.UtcNow
        }
    }));

app.Run();

public partial class Program;
