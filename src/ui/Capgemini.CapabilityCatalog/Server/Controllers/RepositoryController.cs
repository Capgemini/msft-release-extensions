using Capgemini.CapabilityCatalog.Server.Services;
using Capgemini.CapabilityCatalog.Shared.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Identity.Web.Resource;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace Capgemini.CapabilityCatalog.Server.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    [RequiredScope(RequiredScopesConfigurationKey = "AzureAd:Scopes")]
    public class RepositoryController : ControllerBase
    {
        private readonly ILogger<ScaffolderController> _logger;
        private readonly ICapabilityDataService _service;

        public RepositoryController(ILogger<ScaffolderController> logger, ICapabilityDataService service)
        {
            _logger = logger;
            _service = service;
        }

        [HttpGet]
        public async Task<IEnumerable<Repository>> Get()
        {
            return await _service.GetRepositories();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="value"></param>
        [HttpPost]
        public async void UpdateRepo([FromBody] Repository value)
        {
            _service.UpdateRepository(value);
        }
    }
}
