<#
    .SYNOPSIS
    Stop-SQLService
    .DESCRIPTION
    Stop SQL Server service.
    .PARAMETER serverInstance
    This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
    .PARAMETER services
    This is one or more services to be stopped. 
    Possible values are: 'sql','agent','browser'.
    .EXAMPLE
    Stop-SQLService -serverInstance Server\Instance -services 'sql'
    .INPUTS
    .OUTPUTS
    .NOTES
    .LINK
#> 
function Stop-SQLService {
  param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$ServerInstance,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateSet( 'sql','agent','browser')][String[]]$services
  )
  begin {
    [void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
    $Server = New-Object Microsoft.SqlServer.Management.Smo.Server $serverInstance
    $ver = $Server.Information.VersionMajor 

    $serverName = $serverInstance.Split('\')[0]
    $instance = $serverInstance.Split('\')[1]

    if ($instance -eq $null) {
      $instance = 'MSSQLSERVER'
    } 
  }

  process {
    try {
      foreach ($service in $services) {   
        switch ($service)
        {
          'agent' { if ($instance -eq  'MSSQLSERVER') { $searchstrg = 'SQLSERVERAGENT' } else { $searchstrg = 'SQLAgent$' + $instance }}
          'sql'   { if ($instance -eq 'MSSQLSERVER') { $searchstrg = $instance } else { $searchstrg = 'MSSQL$' + $instance }}
          'browser'  { $searchstrg = 'SQLBrowser'}
        }
        $SqlService = Get-Service | Where-Object {$_.name -like $searchstrg }	
        $ServiceName = $SqlService.Name
        if($SqlService.Status -eq 'Running') {
          write-verbose "Stopping service $ServiceName..."
          $SqlService.DependentServices | foreach-object {Stop-Service -Inputobject $_}
          stop-service $sqlService
          $SqlService.WaitForStatus('Stopped')
          write-verbose "Service $ServiceName is stopped"
        }
        else { write-verbose "Service $ServiceName is already stopped" }
      }
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
  end { $message = "Stopping service on `"$servername`".";  }
}