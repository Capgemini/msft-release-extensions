using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Capgemini.CapabilityCatalog.Shared.Models
{
    public class Repository : BaseDocument
    {
        public string? Url { get; set; }

        public string LastReviewedBy { get; set; }

        public DateTime LastReviewedOn { get; set; }

        public List<Review>? Reviews { get; set; }

    }
}
