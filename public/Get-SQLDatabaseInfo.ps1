#requires -Version 3
<#
    .SYNOPSIS
    Get database info for a SQL instance.
    .DESCRIPTION
    This function will get database information for a SQL instance.
    .PARAMETER serverInstance
    This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
    .PARAMETER dbname
    This is a name or list of names of databases. 
    If the parameter is empts all databases will be used.
    .EXAMPLE
    Get-SQLDatabaseInfo -serverInstance Server\Instance -dbname 'test','test1' -verbose
    .INPUTS
    .OUTPUTS
    Custom Object with database information.
    .NOTES
    .LINK
#>
function Get-SQLDatabaseInfo 
{
  param (
    [Parameter(Mandatory,ValueFromPipeline = $true)][string]$ServerInstance,
  [Parameter(ValueFromPipeline = $true)][string]$dbname )
    
  begin {
    $null = [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
  }
  process {
    try 
    {
      $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerInstance
           
      if(!($dbname))
      {
        $dbs = ($server.Databases)
      }
      else 
      {
        $dbs = ($server.Databases) | Where-Object -FilterScript {
          $_.Name -in $dbname
        }
      }


      $databaseinfo = 
      foreach($database in $dbs) 
      {
        $db = $server.Databases[$database.Name]
        Write-Verbose -Message "Get database info for $db ..."
                    
        New-Object -TypeName PSObject -Property ([Ordered]@{
            'DBName' = $db.name
            'Status' = $db.Status
            'IsSystem' = $db.IsSystemObject
            'Version' = $db.Version
        })
      }
      
		
      return $databaseinfo
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
  end {  Write-Verbose -Message "Database infor collected on `"$ServerInstance`"." }
}
