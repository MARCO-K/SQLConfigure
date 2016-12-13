#requires -Version 3.0
function Stop-SQLService 
{
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

  param (
    [Parameter(Mandatory,ValueFromPipeline)][ValidateNotNullOrEmpty()][string]$ServerInstance,
    [Parameter(Mandatory,ValueFromPipeline)][ValidateSet( 'sql','agent','browser')][String[]]$services
  )
  begin {}

  process {
    try 
    {
      foreach ($service in $services) 
      {
        $serverName = $ServerInstance.Split('\')[0]
        $instance = $ServerInstance.Split('\')[1]

        if ($instance -eq $null) 
        {
          $instance = 'MSSQLSERVER'
        } 
        
        switch ($service)
        {
          'agent' 
          {
            if ($instance -eq 'MSSQLSERVER') 
            {
              $searchstrg = 'SQLSERVERAGENT' 
            }
            else 
            {
              $searchstrg = 'SQLAgent$' + $instance 
            }
          }
          'sql'   
          {
            if ($instance -eq 'MSSQLSERVER') 
            {
              $searchstrg = $instance 
            }
            else 
            {
              $searchstrg = 'MSSQL$' + $instance 
            }
          }
          'browser'  
          {
            $searchstrg = 'SQLBrowser'
          }
        }
        $SqlService = Get-Service | Where-Object -FilterScript {
          $_.name -like $searchstrg 
        }	
        $ServiceName = $SqlService.Name
        if($SqlService.Status -eq 'Running') 
        {
          Write-Verbose -Message "Stopping service $ServiceName..."
          $SqlService.DependentServices | ForEach-Object -Process {
            Stop-Service -InputObject $_
          }
          Stop-Service -InputObject $SqlService
          $SqlService.WaitForStatus('Stopped')
          Write-Verbose -Message "Service $ServiceName is stopped"
        }
        else 
        {
          Write-Verbose -Message "Service $ServiceName is already stopped" 
        }
      }
    }
    catch
    {
      Write-Error -Message $Error[0]
      $err = $_.Exception
      while ( $err.InnerException ) 
      {
        $err = $err.InnerException
        Write-Output -InputObject $err.Message
      }
    }
  }
  end { Write-Verbose  -Message "Service stopped on `"$serverName`"."
  }
}
