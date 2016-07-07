<#
    .SYNOPSIS
    Get-SqlMaxMemory
    .DESCRIPTION
    Get max memory property from SQL Server instance
    .PARAMETER serverInstance
    This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
    .EXAMPLE
    Get-SqlMaxMemory -serverInstance Server\Instance.
    .INPUTS
    .OUTPUTS
    Integer in MB 
    -1 if memory is set to default of 2GB	
    .NOTES
    .LINK
		
#>
function Get-SqlMaxMemory {
  param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$ServerInstance
  )

  begin {
    [void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
    $server = New-Object Microsoft.SqlServer.Management.Smo.Server $serverInstance
  }
  process {
    try {
      Write-Verbose 'Get max memory property from SQL Server...'

		

      $maxMemory = $server.Configuration.MaxServerMemory.ConfigValue
      if ($maxMemory -eq 2147483647) {
        Write-Verbose 'Max memory is set to unlimited'
        $maxMemory = -1
      }

      return $maxMemory
    }
    catch [Exception] {
      Write-Error $Error[0]
      $err = $_.Exception
      while ( $err.InnerException ) {
        $err = $err.InnerException
        Write-Output $err.Message
      }
    }
    end { $message = "Getting SqlMaxMemory for `"$serverInstance`".";  }
  }
}
