Describe "CreateReleaseNotesTest" {
	Context "Exists" {
		It "CreateReleaseNotesTest" {

			$scriptPath = "$PSScriptRoot\..\src\extensions\tasks\release-notes\CreateReleaseNotes.ps1"

			& "$scriptPath" -AdoAccountName:"Capgemini_UK" `
			-AdoProjectName:"Capgemini_UK" `
			-AdoUser:"Capgemini" `
			-AdoToken:"[TOKEN]" `
			-ReleaseId:79 `
			-DefinitionId: 6 `
			-DefinitionEnvironmentId: 6 `
			-WikiId: "FluentTestEngine.wiki" `
			-WikiPagePath: "WIKI/Release Notes" `
			-StageName: "DEV" `
			-ReleaseNoteField: "Custom.ReleaseNotes" `
		}
	}
}