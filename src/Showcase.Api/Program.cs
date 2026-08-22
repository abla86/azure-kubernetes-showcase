using Serilog;

var builder = WebApplication.CreateBuilder(args);

builder.Host.UseSerilog((context, configuration) =>
{
    configuration
        .Enrich.FromLogContext()
        .WriteTo.Console();
});

builder.Services.AddOpenTelemetry()
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
        metrics.AddAspNetCoreInstrumentation();
    });

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
