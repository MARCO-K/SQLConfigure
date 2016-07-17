<#
    .SYNOPSIS
    Get-SQLRecommendedMemory
    .DESCRIPTION
    Get recommended memory property from SQL Server instance.
    .PARAMETER serverInstance
    This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
    .EXAMPLE
    Get-SQLRecommendedMemory -serverInstance Server\Instance.
    .INPUTS
    .OUTPUTS
    Integer in MB	
    .NOTES
    Only if server has more than 4GB memory
    .LINK
		
#>
function Get-SQLRecommendedMemory {
  param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$ServerInstance
  )

  begin {
    $null = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
    $server = New-Object Microsoft.SqlServer.Management.Smo.Server $serverInstance
    $sqlmemory = $server.Configuration.MaxServerMemory.ConfigValue
    $totalmemory = $server.PhysicalMemory
  }

  process { 
    try {

      if($totalmemory % 1024 -ne 0) { $totalmemory = $totalmemory +1 }
    
      if ($totalMemory -ge 4096) {
        $sql_mem = $totalMemory * 0.9 ;
        $sql_mem -= ($sql_mem % 1024) ; 
      }
      else {$sql_mem = $totalmemory}
      return $sql_mem
    }
    catch{
      Write-Error $Error[0]
      $err = $_.Exception
      while ( $err.InnerException ) {
        $err = $err.InnerException
        Write-Output $err.Message
      }
    }
  }
  end { $message = "Getting SQLRecommendedMemory for `"$serverInstance`"." }
}
