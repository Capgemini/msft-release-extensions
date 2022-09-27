Describe "AdoScaffolders-Setup" {
	Context "Exists" {
		It "ScaffoldsNewOrganisationProcess" {

			$scriptPath = "$PSScriptRoot\..\..\..\..\src\scaffolders\azure-devops\Organisation\setup.ps1"

			& "$scriptPath" -AdoAccountName:"kriss365" `
			-AdoToken:"<Token>" `
			-NameOfCustomisedProcess:"AgileKrs" `

		}
	}
}