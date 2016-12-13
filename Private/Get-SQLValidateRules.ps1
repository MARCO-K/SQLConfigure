  $ServerInstance = 'sql1\s123' 
  $dbname = 'tempdb'    
  $null = [Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
  #create initial SMO object
  $server = New-Object -TypeName ('Microsoft.SqlServer.Management.Smo.Server') -ArgumentList $ServerInstance

  $cores = $server.Processors
  if($cores -gt 4) { $cores = 4}
  $counts= (Find-DatafileCount -ServerInstance $ServerInstance)
  $count = ($counts | Where-Object { $_.Database -eq $dbname }).filecount


  $check =
  
  New-Object -TypeName PSObject -Property (@{
      'Rule' = 'FileCount'
      'Recommended' = $cores
      'Current' = $count
      'pass' = ($count -gt $cores -and $count % 2 -eq 0)
  }    )
  


  $check