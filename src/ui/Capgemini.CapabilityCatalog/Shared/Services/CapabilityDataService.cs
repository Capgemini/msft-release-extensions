using Capgemini.CapabilityCatalog.Shared.Models;


namespace Capgemini.CapabilityCatalog.Server.Services
{
    public class CapabilityDataService : ICapabilityDataService
    {
        private IRepository<Scaffolder> scaffoldRepo;
        private IRepository<Repository> repositoryRepo;
        private IRepository<Library> packages;

        public CapabilityDataService(IRepository<Scaffolder> scaffoldRepo, IRepository<Repository> repositoryRepo, IRepository<Library> packages)
        {
            this.scaffoldRepo = scaffoldRepo;
            this.repositoryRepo = repositoryRepo;
            this.packages = packages;
        }

        public async Task<IEnumerable<Library>> GetPackages()
        {
            return await packages.GetAllAsync();
        }

        public async Task<IEnumerable<Repository>> GetRepositories()
        {
            return await repositoryRepo.GetAllAsync();
        }

        public async Task<IEnumerable<Scaffolder>> GetScaffolders()
        {
            return await scaffoldRepo.GetAllAsync();
        }

        public async void UpdateRepository(Repository value)
        {
             await repositoryRepo.UpdateAsync(value.id,value);
        }
    }
}
