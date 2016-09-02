function Find-DatafileCount 
{ 
  param (
    [Parameter(Mandatory,ValueFromPipeline)][string]$ServerInstance
  )
  $null = [Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
  #create initial SMO object
  $server = New-Object -TypeName ('Microsoft.SqlServer.Management.Smo.Server') -ArgumentList $ServerInstance
     
  $databases = $server.Databases

  foreach($database in $databases)
  {
    # Get the filegroups for the database
    $filegroups = $database.FileGroups

    # Loop through all the filegroups
    foreach($filegroup in $filegroups)
    {
      # Get all the data files from the filegroup
      $i = ($filegroup.Files | Measure-Object).count
    }
    New-Object -TypeName PSObject -Property (@{
        'database' = $database.Name
        'filecount' = $i          
    })
  }
}
