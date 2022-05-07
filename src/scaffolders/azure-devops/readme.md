# Intro
A helper for customising Defra Azure DevOps instances with a professional template.

# Organisation Customisation Scaffolder

## Setup
Clone the repo and run Setup.ps1 using Powershell

-Arguments
- $AdoAccountName (The organisation name of the ADO instance)
- $AdoToken (PAT Token for Auth)
- $InheritedProcessName (Supply the name of the customised Template e.g DefraCore)

# Project Scaffolder

## Setup
Clone the repo and run Setup.ps1 using Powershell

-Arguments
- $AdoAccountName (The organisation name of the ADO instance)
- $AdoToken (PAT Token for Auth)
- $InheritedProcessName (Supply the name of the customised Template e.g DefraCore)
- $ProjectName (Supply the name of the new project e.g. DEFRA-EUX-DATA)
- $ConfigFileName (The name of the config file from the project-templates folder)

## Sample Config (Example)

{
    "teams" : [
        {"name" : "TeamUI"},
        {"name" : "TeamBackEnd"}
    ],
    "iterations" : [
        {"name" : "Discovery", "numberOfSprints" : 2},
        {"name" : "User Research", "parentPath" : "Discovery"},
        {"name" : "Alpha", "numberOfSprints" : 12},
        {"name" : "Private Beta", "numberOfSprints" : 3},
        {"name" : "Public Beta", "numberOfSprints" : 2},
        {"name" : "Live", "numberOfSprints" : 1},
        {"name" : "Retirement", "numberOfSprints" : 0}
    ],
    "areas" : [
        {   
            "name" : "Technical", 
            "teams" : [
                        {"name" : "TeamUI", "includeSubAreas" : true, "setAsDefaultArea" : true},
                        {"name" : "TeamBackEnd", "includeSubAreas" : true, "setAsDefaultArea" : false}
                      ]
        },
        {"name" : "Tech Debt", "parentPath" : "Technical"},
        {"name" : "Spike", "parentPath" : "Technical"},
        {   
            "name" : "Business", 
            "teams" : [
                        {"name" : "TeamUI", "includeSubAreas" : true, "setAsDefaultArea" : true},
                        {"name" : "TeamBackEnd", "includeSubAreas" : true, "setAsDefaultArea" : false}
                      ]
        }
    ],
    "workItems" : [
        { "title" : "Example NFR1.0", "type" : "User Story", "description" : "Remember to onboard users" },
        { "title" : "Onboard New Team Members", "type" : "User Story", "description" : "Remember to onboard users" },
        { "title" : "Solution Overview", "type" : "User Story", "description" : "Remember to produce a solution overview" },
        { "title" : "ADA Approval", "type" : "User Story", "description" : "Remember ADA Approval" },
        { "title" : "Approved Tooling Review", "type" : "User Story", "description" : "Remember to get tooling Approved" },
        { "title" : "Create WIKI", "type" : "User Story", "description" : "Remember to get tooling Approved" }
    ]  
}

## Wiki Config (Example)

{
    "pages" : 
    [
        {
            "title" : "HomePage",
            "path" : "Home",
            "file" : "HomePage.md"
        },
        {
            "title" : "Delivery",
            "path" : "Home/Delivery",
            "file" : "Delivery.md"
        },
        {
            "title" : "Standards and Tooling",
            "path" : "Home/Delivery/Standards and Tooling",
            "file" : "Standards.md"
        },
        {
            "title" : "Accelerators",
            "path" : "Home/Delivery/Accelerators",
            "file" : "Accelerators.md"
        },       
        {
            "title" : "Onboarding",
            "path" : "Home/Delivery/Onboarding",
            "file" : "Onboarding.md"
        },
        {
            "title" : "Service Requests",
            "path" : "Home/Delivery/Service Requests",
            "file" : "Service Requests.md"
        },
        {
            "title" : "Agile Delivery",
            "path" : "Home/Delivery/Agile",
            "file" : "Agile Delivery.md"
        },
        {
            "title" : "Team Roles and Members",
            "path" : "Home/Delivery/Teams",
            "file" : "Team Roles and Members.md"
        },        
        {
            "title" : "Software Engineering",
            "path" : "Home/Delivery/Standards and Tooling/Software Engineering",
            "file" : "Software Engineering.md"
        },
        {
            "title" : "DevOps",
            "path" : "Home/Delivery/Standards and Tooling/DevOps",
            "file" : "DevOps.md"
        },
        {
            "title" : "Testing",
            "path" : "Home/Delivery/Standards and Tooling/Testing",
            "file" : "Testing.md"
        }            
    ]
}

