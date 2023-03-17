using Capgemini.CapabilityCatalog.Shared.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Capgemini.CapabilityCatalog.Server.Services;
using Microsoft.Identity.Web.Resource;

namespace Capgemini.CapabilityCatalog.Server.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    [RequiredScope(RequiredScopesConfigurationKey = "AzureAd:Scopes")]
    public class ScaffolderController : ControllerBase
    {
        private readonly ILogger<ScaffolderController> _logger;
        private readonly ICapabilityDataService _service;

        public ScaffolderController(ILogger<ScaffolderController> logger, ICapabilityDataService service)
        {
            _logger = logger;
            _service = service;
        }

        [HttpGet]
        public async Task<IEnumerable<Scaffolder>> Get()
        {

            return await _service.GetScaffolders();

        }
    }
}