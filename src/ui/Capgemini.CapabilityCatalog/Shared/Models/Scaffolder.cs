namespace Capgemini.CapabilityCatalog.Shared.Models
{
    public class Scaffolder: BaseDocument
    {
        public List<ScaffoldParameter>? Parameters { get; set; }
        public string? Url { get; set; }
    }
}
