#requires -Version 3.0
function Set-SQLServiceAccount
{
  <#
      .SYNOPSIS
      Set-SQLServiceAccount
      .DESCRIPTION
      Sets account for SQL Server service and/or changes password.
      .PARAMETER ServerInstance
      This is the name of the source server. It's a mandatory parameter beause it is needed to retrieve the service data.
      .PARAMETER services
      This is one or more services to be stopped. 
      Possible values are: 'sql','agent','browser'.
      .PARAMETER $ServiceAccount
      Name of the ServiceAccount (incl. the domain name or prefix).
      .PARAMETER $ServicePassord
      Password for the service account in cear text!
      .EXAMPLE
      Set-SQLServiceAccount -server Server -services 'sql, agent'
      .INPUTS
      .OUTPUTS
      .NOTES
      .LINK
  #> 

  param (
    [Parameter(Mandatory,ValueFromPipeline)][ValidateNotNullOrEmpty()][string]$ServerInstance,
    [Parameter(Mandatory,ValueFromPipeline)][ValidateSet( 'sql','agent')][String[]]$services,
    [Parameter(Mandatory,ValueFromPipeline)][ValidateNotNullOrEmpty()][string]$ServiceAccount,
    [Parameter(Mandatory,ValueFromPipeline)][ValidateNotNullOrEmpty()][String]$ServicePassord
  )
  begin {
  Write-Verbose -Message ('Testing  service account for {0}...' -f $ServiceAccount)
  $account_test =(new-object -TypeName directoryservices.directoryentry -ArgumentList '',$ServiceAccount,$ServicePassord).psbase.name -ne $null
  if(!($account_test)) { 
    Write-Error -Message ('Service account or password is not valid {0}...' -f $ServiceAccount)
    EXIT 
    }

  }

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

        }
        $null = $svc = Get-WmiObject -ComputerName $serverName -Query "SELECT * FROM Win32_Service WHERE Name = '$searchstrg'"
        
        Write-Verbose -Message ('Changing service account for {0}...' -f $svc.Name)
        $null = $svc.change($null,$null,$null,$null,$null,$null,$ServiceAccount,$ServicePassord,$null,$null,$null)

        if($svc.State -eq 'Running')
        {
        Write-Verbose -Message ('Stopping service {0}...' -f $svc.Name)
        $svc.GetRelated() | Where-Object { $_.Name -ne $serverName } | ForEach-Object { $null=  $_.StopService() }
        $null = $svc.StopService()
        while($svc.Started)
            {
            Start-Sleep -Seconds 1
            Write-Verbose -Message ('Stopping service {0}...' -f $svc.Name)
            $null = $svc = Get-WmiObject -ComputerName $serverName -Query "SELECT * FROM Win32_Service WHERE Name = '$searchstrg'"
            }
        }

        Write-Verbose -Message ('Starting service {0}...' -f $svc.Name)
        $null = $svc.StartService()
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
  end { Write-Verbose -Message ('Service account changed on {0}.' -f $serverName)
  }
}
