namespace Capgemini.CapabilityCatalog.Shared.Models
{
    public class Scaffolder
    {
        public string? Name { get; set; }
        public string? Description { get; set; }
        public List<ScaffoldParameter>? Parameters { get; set; }
        public string? Url { get; set; }
    }
}
