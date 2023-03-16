using Capgemini.CapabilityCatalog.Shared.Models;


namespace Capgemini.CapabilityCatalog.Server.Services
{
    public class CapabilityDataService : ICapabilityDataService
    {
        private IRepository<Scaffolder> _repo;

        public CapabilityDataService(IRepository<Scaffolder> repo)
        {
            this._repo = repo;
        }

        public async Task<IEnumerable<Scaffolder>> GetScaffolders()
        {
            return await _repo.GetAllAsync();
        }

    }
}
