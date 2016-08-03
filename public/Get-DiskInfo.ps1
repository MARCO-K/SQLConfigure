#requires -Version 3
Function Get-DiskInfo
{
  <#
      .SYNOPSIS
      Displays Disk information for all local drives on a server.
      .DESCRIPTION
      Returns a custom object with Server name, name of disk, label of disk, total size, free size percent free and allocation unit size.
      .PARAMETER serverInstance
      This is the name of the source instance. 
      It's a mandatory parameter beause it is needed to retrieve the data.
      .PARAMETER Unit
      Display the disk space information in a specific unit. 
      Valid values incldue 'KB', 'MB', 'GB', 'TB', and 'PB'. Default is GB.
      .NOTES 
      .EXAMPLE
      Get-DiskInfo -serverInstance sqlserver
      Get-DiskInfo -serverInstance server1, server2, server3 -Unit MB
  #>
  [CmdletBinding()]
  Param (
    [parameter(Mandatory, ValueFromPipeline = $true)][string[]]$serverInstance,
    [ValidateSet('KB', 'MB', 'GB', 'TB', 'PB')]
    [String]$Unit = 'GB'
  )
	
  BEGIN
  {
    $measure = "1$Unit"
    $query = 'select SystemName, Name, Description, FileSystem, Size, FreeSpace, DriveType, MediaType from Win32_LogicalDisk where MediaType = 12'
			
  }
  process{
    if($serverInstance -contains '\') 
    {
      $serverInstance = $serverInstance.Split('\')[0]
    }
			
    try
    {
      Write-Verbose -Message "Collection disk information on `"$serverInstance`"."
      $disks = Get-WmiObject -ComputerName $serverInstance -Query $query | Sort-Object -Property Name
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
    
    $diskinfo = 
    foreach ($disk in $disks)
    {
      $total = '{0:n2}' -f ($disk.Size/$measure)
      $free = '{0:n2}' -f ($disk.Freespace/$measure)
      $percentfree = '{0:n2}' -f (($disk.Freespace / $disk.Size) * 100)

                 
      New-Object -TypeName PSObject -Property ([Ordered]@{
          'Server'    = $disk.SystemName
          'Name'      = $disk.Name
          'Description' = $disk.Description
          "SizeIn$Unit" = $total
          "FreeIn$Unit" = $free
          'PercentFree' = $percentfree
          'FileSystem' = $disk.FileSystem
          'MediaType' = $disk.MediaType
          'DriveType' = $disk.DriveType
      })
    }
    $diskinfo |
    Sort-Object -Property Server, Name |
    Format-Table
      
  }

        
            
		
  END
  {
    Write-Verbose -Message "Disk information collected on `"$serverInstance`"."
  }
}
