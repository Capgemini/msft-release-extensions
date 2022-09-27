Describe "AdoScaffolders-Setup" {
	Context "Exists" {
		It "ScaffoldsNewProject" {

			$scriptPath = "$PSScriptRoot\..\..\..\..\src\scaffolders\azure-devops\Project\setup.ps1"

			& "$scriptPath" -AdoAccountName:"kriss365" `
			-AdoToken:"<Token>" `
			-InheritedProcessName:"AgileKrs" `
			-ProjectName:"krs-tst1" `
			-ConfigurationType:"Capgemini" `

		}
	}
}