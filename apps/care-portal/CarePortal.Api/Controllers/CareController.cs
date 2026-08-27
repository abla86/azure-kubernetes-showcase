using CarePortal.Api.Models;
using Microsoft.AspNetCore.Mvc;

namespace CarePortal.Api.Controllers;

[ApiController]
[Route("api/care")]
public sealed class CareController : ControllerBase
{
    private static readonly List<CareItem> Items = [];

    [HttpGet]
    public ActionResult<IEnumerable<CareItem>> GetItems() => Ok(Items);

    [HttpPost]
    public ActionResult<CareItem> CreateItem(CareItem item)
    {
        if (string.IsNullOrWhiteSpace(item.Title))
            return BadRequest("Title is required.");

        item.Id = Guid.NewGuid();
        item.CreatedAt = DateTimeOffset.UtcNow;
        Items.Add(item);

        return Created($"/api/care/{item.Id}", item);
    }
}
