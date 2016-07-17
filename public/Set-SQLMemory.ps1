<#
    .SYNOPSIS
    Set-SQLMemory
    .DESCRIPTION
    Set min. and max. memory property from SQL Server instance.
    .PARAMETER serverInstance
    This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
    .PARAMETER maxMem
    This value sets the MaxServerMemory value.
    If the parameter is empty the SQLRecommendedMemory value is used.
    .PARAMETER minMem
    This value sets the MinServerMemory value.
    If the parameter is empty the value 0 is used.
    .EXAMPLE
    Set-SQLMemory -serverInstance Server\instance -maxMem '2048' -minMem 0
    .INPUTS
    .OUTPUTS
    .NOTES
    Only if server has more than 4GB memory
    .LINK
		
#>
function Set-SQLMemory {  
  param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$ServerInstance,
    [int]$maxMem, 
    [int]$minMem
  ) 

  Begin {
    $null = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
    $server = New-Object Microsoft.SqlServer.Management.Smo.Server $serverInstance
    $max = $server.Configuration.MaxServerMemory.ConfigValue
    $min = $server.Configuration.MinServerMemory.ConfigValue
  }
  
  Process {
    try { 
      if(!($maxMem)) {
        $maxMem = Get-SQLRecommendedMemory($serverInstance)
        write-verbose "MaxServerMemory will be set to recommend value: $maxMem"
      }
      if(!($minMem)) {
        $minMem = 0
        write-verbose "MinServerMemory will be set to recommend value: $minMem"
      }

      $server.Configuration.MaxServerMemory.ConfigValue = $maxMem
      $server.Configuration.MinServerMemory.ConfigValue = $minMem
      $server.Configuration.Alter()
      Write-Verbose "MaxServerMemory ($maxMem) and MinServerMemory ($minMem) for `"$serverInstance`"."
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
  End { $message = "Setting MaxServerMemory and MinServerMemory for `"$serverInstance`"." }
}