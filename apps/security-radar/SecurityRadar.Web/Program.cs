using System.Diagnostics;
using System.Text.Json;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.RateLimiting;
using OpenTelemetry.Metrics;
using OpenTelemetry.Trace;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    options.AddFixedWindowLimiter("DeceptionWall", limiterOptions =>
    {
        limiterOptions.PermitLimit = 10;
        limiterOptions.Window = TimeSpan.FromSeconds(10);
        limiterOptions.QueueLimit = 0;
    });
});

var otelEnabled = string.Equals(
    builder.Configuration["OTEL_ENABLED"],
    "true",
    StringComparison.OrdinalIgnoreCase);

if (otelEnabled)
{
    builder.Services.AddOpenTelemetry()
        .WithTracing(tracing => tracing.AddAspNetCoreInstrumentation())
        .WithMetrics(metrics => metrics.AddAspNetCoreInstrumentation());
}

builder.Services.AddSingleton<SecurityEventStore>();

var app = builder.Build();
app.UseRateLimiter();

var deceptionCounter = app.Services.GetRequiredService<SecurityEventStore>().Counter;

app.MapGet("/health", () => Results.Ok(new { status = "healthy" }));

app.MapGet("/api/status", () => Results.Ok(new
{
    status = "operational",
    rateLimiting = true,
    structuredSecurityEvents = true,
    ghostRoute = true,
    telemetryEnabled = otelEnabled
}));

app.MapMethods("/ghost/{**path}",
    new[] { "GET", "POST", "PUT", "PATCH", "DELETE" },
    async (HttpContext context, ILogger<Program> logger, SecurityEventStore store) =>
{
    var started = Stopwatch.GetTimestamp();
    var route = NormalizeRoute(context.Request.Path);
    var safeRoute = SanitizeForLog(route);

    logger.LogWarning(
        "SecurityDeceptionEvent Route={Route} Classification={Classification} Action={Action}",
        safeRoute,
        "controlled-decoy",
        "logged-and-rejected");

    deceptionCounter.Add(route);

    await Task.Delay(TimeSpan.FromSeconds(1.5), context.RequestAborted);
    var elapsed = (long)Stopwatch.GetElapsedTime(started).TotalMilliseconds;

    store.Record(route, "ghost-route-rejected", elapsed);

    return Results.NotFound(new
    {
        detected = true,
        deception = true,
        action = "Decoy route rejected",
        delayMs = elapsed,
        timestamp = DateTimeOffset.UtcNow
    });
}).RequireRateLimiting("DeceptionWall");

app.MapGet("/api/events", (SecurityEventStore store) =>
    Results.Ok(store.Events));

app.Run();

static string NormalizeRoute(PathString path)
{
    var value = path.ToString();
    return value.Length > 512 ? value[..512] : value;
}

static string SanitizeForLog(string value) =>
    value.Replace("\r", "", StringComparison.Ordinal)
         .Replace("\n", "", StringComparison.Ordinal)
         .Replace("\t", " ", StringComparison.Ordinal);

public sealed class SecurityEventStore
{
    private readonly object _gate = new();
    private readonly List<SecurityEvent> _events = new();
    public SecurityEventCounter Counter { get; } = new();

    public IReadOnlyList<SecurityEvent> Events
    {
        get
        {
            lock (_gate)
            {
                return _events.ToArray();
            }
        }
    }

    public void Record(string route, string classification, long elapsedMs)
    {
        lock (_gate)
        {
            _events.Add(new SecurityEvent(
                SanitizeForLog(route),
                classification,
                elapsedMs,
                DateTimeOffset.UtcNow));

            if (_events.Count > 100)
                _events.RemoveAt(0);
        }
    }

    private static string SanitizeForLog(string value) =>
        value.Replace("\r", "", StringComparison.Ordinal)
             .Replace("\n", "", StringComparison.Ordinal)
             .Replace("\t", " ", StringComparison.Ordinal);
}

public sealed class SecurityEventCounter
{
    private long _count;
    public long Count => Interlocked.Read(ref _count);
    public void Add(string _) => Interlocked.Increment(ref _count);
}

public sealed record SecurityEvent(
    string Route,
    string Classification,
    long DelayMs,
    DateTimeOffset Timestamp);

public partial class Program { }
