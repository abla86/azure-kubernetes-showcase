using System.Collections.Concurrent;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddHealthChecks();

var app = builder.Build();
app.UseDefaultFiles();
app.UseStaticFiles();
app.MapHealthChecks("/health");

var events = new ConcurrentQueue<object>();

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

// Controlled deception endpoint. It never performs an external action.
app.MapPost("/api/simulate-attack", async () =>
{
    var started = Stopwatch.GetTimestamp();
    const int delay = 2000;
    await Task.Delay(delay);
    var elapsed = (long)Stopwatch.GetElapsedTime(started).TotalMilliseconds;

    Record("/api/simulate-attack", "controlled-simulation-rejected", elapsed);

    return Results.BadRequest(new
    {
        detected = true,
        simulation = true,
        action = "Request rejected after controlled delay",
        delayMs = elapsed,
        timestamp = DateTimeOffset.UtcNow
    });
});

// Ghost route / honey-token demonstration.
// It records only a local application event; no IP collection or external alerting.
app.MapMethods("/ghost/{**path}", new[] { "GET", "POST", "PUT", "PATCH", "DELETE" }, async (HttpContext context) =>
{
    var started = Stopwatch.GetTimestamp();
    const int delay = 1500;
    await Task.Delay(delay);
    var elapsed = (long)Stopwatch.GetElapsedTime(started).TotalMilliseconds;

    Record(context.Request.Path, "ghost-route-rejected", elapsed);

    return Results.NotFound(new
    {
        detected = true,
        deception = true,
        action = "Decoy route rejected",
        delayMs = elapsed,
        timestamp = DateTimeOffset.UtcNow
    });
});

app.MapGet("/api/events", () =>
    Results.Ok(events.Reverse().Take(50)));

app.MapGet("/api/status", () => Results.Ok(new
{
    service = "security-radar",
    status = "operational",
    controlledSimulation = true,
    ghostRoute = true,
    localEventFeed = true,
    timestamp = DateTimeOffset.UtcNow
}));

app.Run("http://0.0.0.0:8080");
