using Capgemini.CapabilityCatalog.Shared.Models;

namespace Capgemini.CapabilityCatalog.Server.Services
{
    public interface ICapabilityDataService
    {
        Task<IEnumerable<Scaffolder>> GetScaffolders();
    }
}