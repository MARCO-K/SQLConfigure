#requires -Version 3
Function Get-DiskSpace
{
    <#
            .SYNOPSIS
            Displays Disk information for all local drives on a server
	
            .DESCRIPTION
            Returns a custom object with Server name, name of disk, label of disk, total size, free size and percent free.
            .PARAMETER serverInstance
            This is the name of the source instance. 
            It's a mandatory parameter beause it is needed to retrieve the data.
            .PARAMETER Unit
            Display the disk space information in a specific unit. 
            Valid values incldue 'KB', 'MB', 'GB', 'TB', and 'PB'. Default is GB.
            .NOTES 
            .EXAMPLE
            Get-DiskSpace -serverInstance sqlserver
            Get-DiskSpace -serverInstance server1, server2, server3 -Unit MB
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
        $query = 'Select SystemName, Name, DriveType, FileSystem, FreeSpace, Capacity, Label from Win32_Volume where DriveType = 2 or DriveType = 3'
			
    }
    process{
        if($serverInstance -contains '\') 
        {
            $serverInstance = $serverInstance.Split('\')[0]
        }
        $alldisks = @()
			
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
			
        foreach ($disk in $disks)
        {
            if (!$disk.name.StartsWith('\\'))
            {
                $total = '{0:n2}' -f ($disk.Capacity/$measure)
                $free = '{0:n2}' -f ($disk.Freespace/$measure)
                $percentfree = '{0:n2}' -f (($disk.Freespace / $disk.Capacity) * 100)
					
                $alldisks += [PSCustomObject]@{
                    Server      = $serverInstance
                    Name        = $disk.Name
                    Label       = $disk.Label
                    "SizeIn$Unit" = $total
                    "FreeIn$Unit" = $free
                    PercentFree = $percentfree
                }
            }
        }
        return $alldisks
    }
		
    
		
    END
    {
        Write-Verbose -Message "Disk information collected on `"$serverInstance`"."
    }
}
