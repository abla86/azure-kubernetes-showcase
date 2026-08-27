namespace CommunityHub.Api.Models;

public sealed class ResourceItem
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Name { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public string Holder { get; set; } = string.Empty;
    public bool IsAvailable { get; set; } = true;
}
