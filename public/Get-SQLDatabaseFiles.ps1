#requires -Version 3.0
function Get-SQLDatabaseFiles
{
  <# 
      .SYNOPSIS
      Get the database files information for each database. 
      .DESCRIPTION
      Get the database files information for each database. 
      System datbase can be excluded. 

      .PARAMETER serverInstance
      This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.

      .PARAMETER nosystem
      This is used to return only  details for non-system databases.

      .PARAMETER dbfilter
      This is used to return only  details for filtered databases.

      .EXAMPLE
      Get-Get-SQLDatabaseFiles -ServerInstance "SQL01\INST01" -port 4321
      .INPUTS
      .OUTPUTS
      System.Array
      .NOTES
      .LINK
  #>

  param (
    [Parameter(Mandatory,ValueFromPipeline)][ValidateNotNullOrEmpty()][string]$ServerInstance,
    [Parameter(ValueFromPipeline)][switch]$nosystem = $false,
    [Parameter(ValueFromPipeline)][String[]]$dbfilter = ''
  )
  begin { 
     
    $null = [Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
  }
  process { 
    #create initial SMO object
    $server = New-Object -TypeName ('Microsoft.SqlServer.Management.Smo.Server') -ArgumentList $ServerInstance

    # Get all the databases

    if($dbfilter)
    {
      $databases = $server.Databases | Where-Object -FilterScript {
        $_.Name -in $dbfilter
      }
    }
    elseif($nosystem) 
    {
      $databases = $server.Databases | Where-Object -FilterScript {
        $_.IsSystemObject -ne $true
      }
    }

    else 
    {
      $databases = $server.Databases
    }

    try 
    { 
      # Loop through all the databases
      $result = 
      foreach($database in $databases)
      {
        # Get the filegroups for the database
        $filegroups = $database.FileGroups

        # Loop through all the filegroups
        foreach($filegroup in $filegroups)
        {
          # Get all the data files from the filegroup
          $files = $filegroup.Files

          # Loop through all the data files
          foreach($file in $files)
          {
            $file | Select-Object `
            -Property @{
              Name       = 'DatabaseName'
              Expression = {
                $database.Name
              }
            }, LogicalName, `
            @{
              Name       = 'FileType'
              Expression = {
                'ROWS'
              }
            }, `
            @{
              Name       = 'Drive'
              Expression = {
                $file.FileName | Split-Path -Resolve -Qualifier
              }
            }, `
            @{
              Name       = 'Directory'
              Expression = {
                $file.FileName | Split-Path -Parent
              }
            }, `
            @{
              Name       = 'FileName'
              Expression = {
                $file.FileName | Split-Path -Leaf
              }
            }, `
            Growth, GrowthType, Size, UsedSpace
          }
        }

        # Get all the data files from the filegroup
        $files = $database.LogFiles

        # Loop through all the log files
        foreach($file in $files)
        {
          $file | Select-Object `
          -Property @{
            Name       = 'DatabaseName'
            Expression = {
              $database.Name
            }
          }, LogicalName, `
          @{
            Name       = 'FileType'
            Expression = {
              'LOG'
            }
          }, `
          @{
            Name       = 'Drive'
            Expression = {
              $file.FileName | Split-Path -Resolve -Qualifier
            }
          }, `
          @{
            Name       = 'Directory'
            Expression = {
              $file.FileName | Split-Path -Parent
            }
          }, `
          @{
            Name       = 'FileName'
            Expression = {
              $file.FileName | Split-Path -Leaf
            }
          }, `
          Growth, GrowthType, Size, UsedSpace
        }
      }
      $result  | Select-Object -Property *
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
  end { Write-Verbose -Message ('Database file information collected for {0}.' -f $serverinstance)
  }
}
