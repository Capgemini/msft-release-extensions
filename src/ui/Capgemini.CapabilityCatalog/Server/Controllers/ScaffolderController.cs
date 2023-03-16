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

            //return new List<Scaffolder>
            //            {
            //                new Scaffolder
            //                {
            //                    Name="DevOps Common Scaffolder",
            //                    Description="A Scaffolder to setup Azure DevOps to match Capgemini standard delivery",
            //                    Parameters = new List<ScaffoldParameter>
            //                        {
            //                            new ScaffoldParameter{  Name="adoProjectName", Value="" },
            //                            new ScaffoldParameter{  Name="repositoryName", Value="" }
            //                       }
            //                },
            //               new Scaffolder {Name="A", Description="b"}
            //}.ToArray();

            //return Enumerable.Range(1, 5).Select(index => new Scaffolder
            //{
            //    Name = $"Scaffolder {index}",
            //    Description = $"Scaffolder {index}"
            //})
            //.ToArray();
        }
    }
}