using Microsoft.Azure.Cosmos;

namespace Capgemini.CapabilityCatalog.Server
{
    public class CosmosDBRepository<T> : IRepository<T> where T : class
    {
        private readonly Container _container;

        public CosmosDBRepository(string endpoint, string key, string databaseName, string containerName)
        {
            var client = new CosmosClient(endpoint, key);
            var database = client.GetDatabase(databaseName);
            _container = database.GetContainer(containerName);
        }

        public async Task<T> GetByIdAsync(string id)
        {
            try
            {
                var response = await _container.ReadItemAsync<T>(id, new PartitionKey(id));
                return response.Resource;
            }
            catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
            {
                return null;
            }
        }

        public async Task<IEnumerable<T>> GetAllAsync()
        {
            var query = _container.GetItemQueryIterator<T>(new QueryDefinition("SELECT * FROM c"));
            var results = new List<T>();
            while (query.HasMoreResults)
            {
                var response = await query.ReadNextAsync();
                results.AddRange(response.ToList());
            }
            return results;
        }

        public async Task<T> AddAsync(T item)
        {
            var response = await _container.CreateItemAsync(item);
            return response.Resource;
        }

        public async Task<T> UpdateAsync(string id, T item)
        {
            var response = await _container.UpsertItemAsync(item, new PartitionKey(id));
            return response.Resource;
        }

        public async Task DeleteAsync(string id)
        {
            await _container.DeleteItemAsync<T>(id, new PartitionKey(id));
        }
    }

    public interface IRepository<T> where T : class
    {
        Task<T> GetByIdAsync(string id);
        Task<IEnumerable<T>> GetAllAsync();
        Task<T> AddAsync(T item);
        Task<T> UpdateAsync(string id, T item);
        Task DeleteAsync(string id);
    }
}
