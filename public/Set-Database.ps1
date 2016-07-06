	<#
			Author: Marco Kleinert
			Version: 1.0
			Version 
			- 1.0 initial version

			.SYNOPSIS

      This script changes some setting for a database.			

			.DESCRIPTION

      This script changes some setting for a database.

			.PARAMETER ServerInstance

			This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.

			.PARAMETER dbname

			This is the name of the database. The dbname has to be valid.

			.PARAMETER recovery

			This parameter sets the recovery model for the database.  The parameter can be empty and no change will happen.
      Valid values are: 'Full','Simple','Bulklogged'.

			.PARAMETER UpdateCompatibilityLevel

      This switch allows to change the database CompatibilityLevel to the instance major version.

      .PARAMETER growth

			This parameter sets growth value for the database.  The parameter can be empty and no change will happen. 
      It must be and integer value. If the value is less or equal to the existing one nothing will change.

      .PARAMETER growthtype

			This parameter sets growthtype  for the database.  The parameter can be empty and no change will happen. 
      If the is equal to the existing one nothing will change.
      Valid values are:'KB','Percent'.

			.EXAMPLE

      Set-Database -ServerInstance 'DEFREON0830\S60039' -dbname 'test' -recovery 'Full' -growth 10240 -GrowthType KB -Verbose -UpdateCompatibilityLevel
	#>
	#requires -Version 3
function Set-Database { 
  param(
        [parameter(Mandatory=$true,ValueFromPipeline=$True)][string]$ServerInstance,
    [parameter(Mandatory=$true,ValueFromPipeline=$True)][string]$dbname, 
        [ValidateSet('Full','Simple','Bulklogged')][string]$recovery,
        [switch]$UpdateCompatibilityLevel,
        [int]$growth,
        [ValidateSet('KB','Percent')][string]$GrowthType
        )

  begin {
    #Load assemblies
    [void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')

    #create initial SMO object
    $server = new-object ('Microsoft.SqlServer.Management.Smo.Server') $ServerInstance

    #creating basic variables
    $db = $server.Databases[$dbname]
    $fg = $db.FileGroups['PRIMARY']
    $logs = $db.LogFiles
    
    switch ($server.VersionMajor) {
         9 { $CompatibilityLevel = 'Version90'  }
        10 { $CompatibilityLevel = 'Version100' }
        11 { $CompatibilityLevel = 'Version110' }
        12 { $CompatibilityLevel = 'Version120' }
      }  
  }

  Process {
      try {

        foreach ($file in $fg.Files) {    
            if ($growth -and $file.Growth -lt $growth) {$file.Growth = $growth } else { Write-Verbose "Growth for $file not changed" }
            if($GrowthType -and $file.GrowthType -ne $GrowthType) { $file.GrowthType = $GrowthType } else { Write-Verbose "GrowthType for $file not changed" }
            write-verbose "$($file.Name) customized"
            }
        
        foreach ($file in $logs) {
            if ($growth -and $file.Growth -le $growth) {$file.Growth = $growth } else { Write-Verbose "Growth for $file not changed" }
            if($GrowthType -and $file.GrowthType -ne $GrowthType) { $file.GrowthType = $GrowthType } else { Write-Verbose "GrowthType for $file not changed" }
            write-verbose "$($file.Name) customized"
            }

        if($recovery -and $db.RecoveryModel -ne $recovery) {
            $db.RecoveryModel = $recovery
            $server.killallprocesses($dbname)
            $db.alter()
            write-verbose "Recovery for $dbname changed to $recovery"
            }
            else { Write-Verbose "Recovery model for $db not changed" }
         
         if($CompatibilityLevel -and $db.CompatibilityLevel -ne 'Version'+$server.VersionMajor) {
            $db.CompatibilityLevel = $CompatibilityLevel
            $server.killallprocesses($dbname)
            $db.alter()
            write-verbose "CompatibilityLevel for $dbname changed to $CompatibilityLevel"
            }
            else { Write-Verbose "CompatibilityLevel for $db not changed" }
            
        }
      catch { Write-host -ForegroundColor Red '$dbname configuration failed' }
    }
  End { write-verbose "Database $dbname configured successfully" }
}
 
