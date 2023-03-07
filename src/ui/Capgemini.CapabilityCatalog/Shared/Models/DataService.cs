
namespace Capgemini.CapabilityCatalog.Shared.Models
{
    /// TODO: introduce interfaces
    public class DataService
    {
        public Scaffolder[]? Scaffolders
        {
            get
            {
                var list = new List<Scaffolder>();

                for (int i = 1; i < 6; i++)
                {
                    list.Add(new Scaffolder()
                    {
                        Name = $"Scaffolder {i}",
                        Description = $"Scaffolder {i}"
                    });
                }
                return list.ToArray();
            }
        }
    }


}
