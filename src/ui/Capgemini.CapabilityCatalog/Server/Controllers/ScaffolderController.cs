using Capgemini.CapabilityCatalog.Shared.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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

        public ScaffolderController(ILogger<ScaffolderController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public IEnumerable<Scaffolder> Get()
        {
            return new List<Scaffolder>
                        {
                            new Scaffolder {Name="DevOps Common Scaffolder", Description="A Scaffolder to setup Azure DevOps to match Capgemini standard delivery"//, Parameters = new List<ScaffoldParameter>
                           // {
                                //new ScaffoldParameter{ DataType= typeof(String), Name="adoAccountName", Value="" },
                                //new ScaffoldParameter{ DataType= typeof(String), Name="adoProjectName", Value="" },
                                //new ScaffoldParameter{ DataType= typeof(String), Name="repositoryName", Value="" }
                        //   }
                        }
            }.ToArray();

            //return Enumerable.Range(1, 5).Select(index => new Scaffolder
            //{
            //    Name = $"Scaffolder {index}",
            //    Description = $"Scaffolder {index}"
            //})
            //.ToArray();
        }
    }
}