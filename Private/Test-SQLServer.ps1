function Test-SQLServer { param([string]$ServerInstance)
  TRY {
    $sqlCon = New-Object Data.SqlClient.SqlConnection
    $sqlCon.ConnectionString = "Data Source=$ServerInstance;Integrated Security=True"
    $sqlCon.open() 
    IF ($sqlCon.State -eq 'Open')
    {
      Write-Verbose "Connection to $ServerInstance is $($sqlCon.State)"
      $sqlCon.Close()
      return $true 
    }
    else {
      Write-Verbose 'SQLAgent is is not running --trying to start...'
      Start-SQLService -services 'agent' -instance $server.InstanceName
    }
  } 
  CATCH { Write-host -ForegroundColor Red "Not available Server: $ServerInstance"}
  try {
    $i = $server.JobServer.Properties['JobServerType'].value
    if($i) {Write-Verbose 'SQLAgent is running'; return $true }
    else {
      Write-Verbose 'SQLAgent is is not running --trying to start...'
      Start-SQLService -services 'agent' -instance $server.InstanceName
    }
  }
  catch{ Write-host -ForegroundColor Red "Not available SQLAgent: $ServerInstance"}
}