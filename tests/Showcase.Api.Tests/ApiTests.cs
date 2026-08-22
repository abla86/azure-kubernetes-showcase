using Microsoft.AspNetCore.Mvc.Testing;

namespace Showcase.Api.Tests;

public class ApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public ApiTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task HealthEndpoint_ReturnsSuccess()
    {
        var response = await _client.GetAsync("/api/health");

        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task InfoEndpoint_ReturnsSuccess()
    {
        var response = await _client.GetAsync("/api/info");

        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task MetricsEndpoint_ReturnsSuccess()
    {
        var response = await _client.GetAsync("/api/metrics");

        Assert.True(response.IsSuccessStatusCode);
    }
}
