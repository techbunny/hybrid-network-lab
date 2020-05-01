configuration TestConfig {
    Node web-RegionA-01 {
       WindowsFeature IIS {
          Ensure               = 'Present'
          Name                 = 'Web-Server'
          IncludeAllSubFeature = $true
       }
    }
 }