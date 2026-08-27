var builder = WebApplication.CreateBuilder(args);
builder.Services.AddHealthChecks();

var app = builder.Build();
app.UseDefaultFiles();
app.UseStaticFiles();
app.MapHealthChecks("/health");

app.MapPost("/api/simulate-attack", async () =>
{
    var started = DateTimeOffset.UtcNow;
    await Task.Delay(TimeSpan.FromSeconds(2));
    return Results.BadRequest(new
    {
        detected = true,
        simulation = true,
        action = "Request rejected after controlled delay",
        delayMs = (int)(DateTimeOffset.UtcNow - started).TotalMilliseconds,
        timestamp = DateTimeOffset.UtcNow
    });
});

app.MapGet("/api/status", () => Results.Ok(new
{
    service = "security-radar",
    status = "operational",
    simulationEndpoint = true,
    timestamp = DateTimeOffset.UtcNow
}));

app.Run("http://0.0.0.0:8080");
