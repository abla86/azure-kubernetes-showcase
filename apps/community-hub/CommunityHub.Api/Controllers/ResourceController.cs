using CommunityHub.Api.Models;
using Microsoft.AspNetCore.Mvc;

namespace CommunityHub.Api.Controllers;

[ApiController]
[Route("api/resources")]
public sealed class ResourceController : ControllerBase
{
    private static readonly List<ResourceItem> Resources =
    [
        new() { Name = "Felles tilhenger", Category = "Utstyr", Holder = "Ingen", IsAvailable = true },
        new() { Name = "Nøkkelsett Bunkers/Bod", Category = "Nøkler", Holder = "Kari Nordmann", IsAvailable = false }
    ];

    [HttpGet]
    public ActionResult<IEnumerable<ResourceItem>> GetResources() => Ok(Resources);

    [HttpPost]
    public ActionResult<ResourceItem> CreateResource(ResourceItem item)
    {
        if (string.IsNullOrWhiteSpace(item.Name) || string.IsNullOrWhiteSpace(item.Category))
            return BadRequest("Name and Category are required.");

        item.Id = Guid.NewGuid();
        Resources.Add(item);

        return Created($"/api/resources/{item.Id}", item);
    }
}
