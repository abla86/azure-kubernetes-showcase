using System.Collections.Concurrent;
using System.Diagnostics;
using System.Diagnostics.Metrics;
using Microsoft.AspNetCore.RateLimiting;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using System.Threading.RateLimiting;

const string serviceName = "security-radar";
var otelEnabled = string.Equals(
    Environment.GetEnvironmentVariable("OTEL_ENABLED"),
    "true",
    StringComparison.OrdinalIgnoreCase);

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddHealthChecks();

builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    options.AddFixedWindowLimiter("DeceptionWall", limiter =>
    {
        limiter.PermitLimit = 2;
        limiter.Window = TimeSpan.FromMinutes(1);
        limiter.QueueLimit = 0;
    });
});

if (otelEnabled)
{
    builder.Services.AddOpenTelemetry()
        .ConfigureResource(resource => resource.AddService(serviceName))
        .WithTracing(tracing => tracing
            .AddAspNetCoreInstrumentation()
            .AddOtlpExporter(options =>
            {
                var endpoint = Environment.GetEnvironmentVariable("OTEL_EXPORTER_OTLP_ENDPOINT");
                if (Uri.TryCreate(endpoint, UriKind.Absolute, out var uri))
                {
                    options.Endpoint = uri;
                }
            }))
        .WithMetrics(metrics => metrics
            .AddAspNetCoreInstrumentation()
            .AddMeter("AzureKubernetesShowcase.SecurityRadar")
            .AddOtlpExporter(options =>
            {
                var endpoint = Environment.GetEnvironmentVariable("OTEL_EXPORTER_OTLP_ENDPOINT");
                if (Uri.TryCreate(endpoint, UriKind.Absolute, out var uri))
                {
                    options.Endpoint = uri;
                }
            }));
}

var app = builder.Build();

app.UseDefaultFiles();
app.UseStaticFiles();
app.UseRateLimiter();

app.Use(async (context, next) =>
{
    context.Response.Headers["X-Clacks-Overhead"] = "GNU Terry Pratchett";
    context.Response.Headers["X-Defense-Depth"] = "Active";
    await next();
});

var events = new ConcurrentQueue<object>();
using var meter = new Meter("AzureKubernetesShowcase.SecurityRadar");
var deceptionCounter = meter.CreateCounter<long>(
    "security.deception.events",
    description: "Controlled deception events");

void Record(string route, string action, long delayMs = 0)
{
    events.Enqueue(new
    {
        timestamp = DateTimeOffset.UtcNow,
        route,
        action,
        delayMs
    });

    while (events.Count > 100 && events.TryDequeue(out _)) { }
}

app.MapHealthChecks("/health");

app.MapPost("/api/simulate-attack", async (
    HttpContext context,
    ILogger<Program> logger) =>
{
    var started = Stopwatch.GetTimestamp();
    await Task.Delay(TimeSpan.FromSeconds(2), context.RequestAborted);
    var elapsed = (long)Stopwatch.GetElapsedTime(started).TotalMilliseconds;

    logger.LogWarning(
        "SecurityDeceptionEvent Route={Route} Classification={Classification} Action={Action}",
        "/api/simulate-attack",
        "controlled-simulation",
        "logged-and-rejected");

    deceptionCounter.Add(1, new KeyValuePair<string, object?>(
        "route", "/api/simulate-attack"));

    Record("/api/simulate-attack", "controlled-simulation-rejected", elapsed);

    return Results.BadRequest(new
    {
        detected = true,
        simulation = true,
        action = "Request rejected after controlled delay",
        delayMs = elapsed,
        timestamp = DateTimeOffset.UtcNow
    });
}).RequireRateLimiting("DeceptionWall");

app.MapMethods("/ghost/{**path}",
    new[] { "GET", "POST", "PUT", "PATCH", "DELETE" },
    async (HttpContext context, ILogger<Program> logger) =>
{
    var started = Stopwatch.GetTimestamp();
    var route = context.Request.Path.ToString();

    logger.LogWarning(
        "SecurityDeceptionEvent Route={Route} Classification={Classification} Action={Action}",
        route,
        "controlled-decoy",
        "logged-and-rejected");

    deceptionCounter.Add(1, new KeyValuePair<string, object?>("route", route));

    await Task.Delay(TimeSpan.FromSeconds(1.5), context.RequestAborted);
    var elapsed = (long)Stopwatch.GetElapsedTime(started).TotalMilliseconds;

    Record(route, "ghost-route-rejected", elapsed);

    return Results.NotFound(new
    {
        detected = true,
        deception = true,
        action = "Decoy route rejected",
        delayMs = elapsed,
        timestamp = DateTimeOffset.UtcNow
    });
}).RequireRateLimiting("DeceptionWall");

app.MapGet("/api/events", () =>
    Results.Ok(events.Reverse().Take(50)));

app.MapGet("/api/status", () => Results.Ok(new
{
    service = serviceName,
    status = "operational",
    controlledSimulation = true,
    ghostRoute = true,
    rateLimiting = true,
    structuredSecurityEvents = true,
    localEventFeed = true,
    telemetryEnabled = otelEnabled,
    timestamp = DateTimeOffset.UtcNow
}));

app.Run("http://0.0.0.0:8080");
