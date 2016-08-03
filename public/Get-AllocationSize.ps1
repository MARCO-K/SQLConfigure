#requires -Version 3
<#
    .SYNOPSIS
    Returns the disk allocation size on the server.
    .DESCRIPTION
    Returns the disk allocation size on the server.
    .PARAMETER serverInstance
    This is the name of the source instance. 
    It's a mandatory parameter beause it is needed to retrieve the data.
    .NOTES
    .OUTPUT
    Custom object with allocation size information.
    .EXAMPLE
    Get-AllocationSize -serverInstance server
#>
function Get-AllocationSize 
{
  param (
    [parameter(Mandatory, ValueFromPipeline = $true)][string[]]$serverInstance
  )

  begin {
    $query = 'select * from Win32_LogicalDisk Where MediaType = 12'
  }
  process {
    if($serverInstance -contains '\') 
    {
      $serverInstance = $serverInstance.Split('\')[0]
    }
    Write-Verbose -Message "Getting disk allocation size on $serverInstance"
    try 
    {
      $LogicalDisks = Get-WmiObject -Query $query | Select-Object -Property Name, MediaType, FileSystem, Size
      $alloc = 
      foreach ($disk in $LogicalDisks)
      {
        $Drive = $disk.Name + '\'
        $fsutil = (fsutil.exe fsinfo ntfsinfo $Drive) 
        $AllocSize = $fsutil |
        Split-Result |
        Select-Object -Property Title, Value |
        Where-Object -FilterScript {
          $_.Title -eq 'Bytes Per Cluster'
        }
        if ($AllocSize.Value -eq 65536)
        {
          $size = $AllocSize.Value
          $match = $true
        }
        else 
        {
          $size = $AllocSize.Value
          $match = $false
        }
        New-Object -TypeName PSObject -Property ([Ordered]@{
            'Disk' = $disk.Name
            '64K' = $match
            'Size' = $size
        })
      }
      return $alloc
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
}
