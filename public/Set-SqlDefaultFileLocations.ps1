<#
	.SYNOPSIS
		Set-SqlDefaultFileLocations
	.DESCRIPTION
		Set default file locations for a SQL Server instance.
	.PARAMETER serverInstance
		This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
  .PARAMETER dataPath
    This is the default directory for data files.
  .PARAMETER logPath
    This is the default directory for trancaction log files.
  .PARAMETER backupPath
    This is the default directory for backup files.
	.EXAMPLE
		.\Set-SqlDefaultFileLocations -serverInstance server01\sql2012
	.INPUTS
	.OUTPUTS
		Default file locations
	.NOTES
	.LINK
#>
function Set-SqlDefaultFileLocations { 
  [cmdletbinding()]
  param([parameter(Mandatory=$true,ValueFromPipeline=$True)][string]$ServerInstance,
      [string]$dataPath,
      [string]$logPath,
      [string]$backupPath
  )

  begin {
    [void][reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
  }
  process {
    try {
      Write-Verbose 'Set SQL Server default file locations...'

      $server = new-object Microsoft.SqlServer.Management.Smo.Server $serverInstance

      if ((Test-Path -path $dataPath) -ne $true) {
        #New-Item $dataPath -type directory
        Throw "Data Path: $dataPath doesn't exist"
      }
      else { $server.Settings.DefaultFile = $dataPath }
		
      if ((Test-Path -path $logPath) -ne $true) {
        #New-Item $logPath -type directory
        Throw "Log Path: $logPath doesn't exist"
      }
      else { $server.Settings.DefaultLog = $logPath }
      
      if ((Test-Path -path $backupPath) -ne $true) {
        #New-Item $logPath -type directory
        Throw "Log Path: $backupPath doesn't exist"
      }
      else { $server.Settings.BackupDirectory = $backupPath }
      
      $server.Settings.Alter()

    }
    catch [Exception] {
      Write-Error $Error[0]
      $err = $_.Exception
      while ( $err.InnerException ) {
        $err = $err.InnerException
        Write-Output $err.Message
      }
    }
  }
  end { Write-Verbose "Default FileLocation changed for `"$ServerInstance`".";}
}