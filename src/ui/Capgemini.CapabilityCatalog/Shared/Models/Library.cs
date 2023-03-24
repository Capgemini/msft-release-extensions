using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Capgemini.CapabilityCatalog.Shared.Models
{
    public class Library : BaseDocument
    {      
        public string? Url { get; set; }
        public int Downloads { get; set; }
        public string? PackageType { get; set; }
        public string? RepoUrl { get; set; }

    }
}
