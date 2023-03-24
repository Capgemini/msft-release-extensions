using Capgemini.CapabilityCatalog.Shared.Models;

namespace Capgemini.CapabilityCatalog.Server.Services
{
    public interface ICapabilityDataService
    {
        Task<IEnumerable<Library>> GetPackages();
        Task<IEnumerable<Repository>> GetRepositories();
        Task<IEnumerable<Scaffolder>> GetScaffolders();
    }
}