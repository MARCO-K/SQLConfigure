#requires -Version 3
Function Get-NTFSInfo
{
  <#
      .SYNOPSIS
      Displays NTFS information for all local drives on a server.
      .DESCRIPTION
      Returns a custom object with NTFS information for all local drives on a server.
      .PARAMETER serverInstance
      This is the name of the source instance. 
      It's a mandatory parameter beause it is needed to retrieve the data.
      .NOTES
      .OUTPUT
      Custom object with NTFS information (disk, name, value) 
      .EXAMPLE
      Get-NTFSInfo -serverInstance sqlserver

  #>
  [CmdletBinding()]
  Param (
    [parameter(Mandatory, ValueFromPipeline = $true)][string[]]$serverInstance
  )
	
  BEGIN
  {
    $measure = "1$Unit"
    $query = 'select * from Win32_LogicalDisk Where MediaType = 12'
			
  }
  process {
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
    $fsutil = 
    foreach ($disk in $disks)
    {
      $Drive = $disk.Name + '\'
      $output = (fsutil.exe fsinfo ntfsinfo $Drive)

      foreach ($line in $output) 
      {
        $info = $line.split(':').Trim()
        #if the value is hex, convert to int
        if ($info[1].startswith('0x0')) 
        {
          $info[1] = [Convert]::ToInt64(($info[1]),16).toString()
        }
        New-Object -TypeName PSObject -Property ([Ordered]@{
            'disk' = $disk.Name
            'name' = $info[0].Replace(' ','_')
            'value' = $info[1]
        })
        $info = $null
      }
    }
    $fsutil | Sort-Object -Property disk, name 
  }
}
