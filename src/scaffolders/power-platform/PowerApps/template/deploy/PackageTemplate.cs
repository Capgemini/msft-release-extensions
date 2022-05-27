namespace XXXXXXXXX.YYYYYYYYY.Deployment
{
    using System.ComponentModel.Composition;
    using Capgemini.PowerApps.PackageDeployerTemplate;
    using Microsoft.Xrm.Tooling.PackageDeployment.CrmPackageExtentionBase;

    /// <summary>
    /// Import package starter frame.
    /// </summary>
    [Export(typeof(IImportExtensions))]
    public class PackageTemplate : PackageTemplateBase
    {
        /// <inheritdoc/>
        public override string GetImportPackageDataFolderName => "PkgFolder";

        /// <inheritdoc/>
        public override string GetImportPackageDescriptionText => "YYYYYYYYY";

        /// <inheritdoc/>
        public override string GetLongNameOfImport => "YYYYYYYYY";

        /// <inheritdoc/>
        public override string GetNameOfImport(bool plural) => "YYYYYYYYY";
    }
}
