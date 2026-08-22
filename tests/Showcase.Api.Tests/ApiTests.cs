namespace Showcase.Api.Tests;

public class ApiTests
{
    [Fact]
    public void ApplicationName_IsCorrect()
    {
        const string application = "Azure Kubernetes Showcase";

        Assert.Equal(
            "Azure Kubernetes Showcase",
            application);
    }
}
