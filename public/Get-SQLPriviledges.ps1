#requires -Version 3
Function Get-SQLPriviledges
{
<#
        .SYNOPSIS
        Displays Windows priviledges for the Service account and/or domain local group on a server.
        .DESCRIPTION
        Displays Windows priviledges for the Service account and/or domain local group on a server.
        It returns the values for a defined list of local security priviledges for the accunts and groups.
        .PARAMETER serverInstance
        This is the name of the source instance. 
        It's a mandatory parameter beause it is needed to retrieve the data.
        .PARAMETER ServiceAccounts
        A list of service accounts to check the granted permissions. 
        If no value is set then the service account of the local instance will be used.
        .PARAMETER DLgroup
        A is the domain local group to check the granted permissions. 
        If no value is set then the DL group of the service account of the local instance will be used.
        .NOTES 
        .EXAMPLE
        Get-SQLPriviledges -serverInstance sqlserver -DLgroup 'doamin\SQLservers'
        Get-DiskSpace -serverInstance server1, server2, server3
#>
    [CmdletBinding()]
    Param (
        [parameter(Mandatory, ValueFromPipeline = $true)][string[]]$serverInstance,
        [parameter(ValueFromPipeline = $true)][String[]]$ServiceAccounts,
        [parameter(ValueFromPipeline = $true)][String]$DLgroup
    )
    Begin {
        # Export the secpol privileges on the machine to a file 
        $filename  = 'secpol.inf'
        $secpol = $null = SecEdit.exe /export /cfg $filename
        $secpol = Get-Content $filename

        $lsps = @('SeManageVolumePrivilege', 'SeServiceLogonRight', 'SeAssignPrimaryTokenPrivilege ', 'SeChangeNotifyPrivilege', 'SeLockMemoryPrivilege', 'SeIncreaseQuotaPrivilege', 'SeIncreaseBasePriorityPrivilege', 'SeIncreaseWorkingSetPrivilege')
    }
    Process {
		if($serverInstance -contains '\') {$serverInstance= $serverInstance.Split('\')[0]}
        Write-Verbose -Message "Getting wWindow priliedges on $serverInstance"
        # Find out the SQL Server services installed on the machine
        if(!($ServiceAccounts)) 
        {
            $SqlService = (Get-WmiObject -ComputerName $serverInstance -Query "SELECT * FROM Win32_Service WHERE PathName LIKE '%sqlservr%'").StartName
        }
        else 
        {
            $SqlService = $ServiceAccounts
        }
        if(!($DLgroup)) 
        {
            $SQLGroup = 'DOM1\CSS_CC11SQLServerService_DS'
        }
        else 
        {
            $SQLGroup = $DLgroup
        }

        $sids = $SqlService, $SQLGroup

        # Loop through each SQL Server service found on the machine

        $priviledges = 
        foreach($sid in $sids) 
        {
            try
            {
                # Find out the SID value of the service account
                $objUser = New-Object -TypeName System.Security.Principal.NTAccount -ArgumentList ($sid)
                $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
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
        
            foreach ($lsp in $lsps)
            {
                # Search for the volumne maintenance task privilege in the output
                $ura = Select-String -Path $filename -Pattern $lsp


                #Find out if the SQL Service account SID exists in the output
                if ($ura.ToString().Contains($strSID.Value))
                {
                    $priv = $true
                    Write-Verbose -Message "SQL Server service account [$sid] has $lsp security privilege"
                }
                else
                {
                    $priv = $false
                    Write-Verbose -Message "[ERR] SQL Server service account [$sid] has no $lsp security privilege"
                }
                New-Object -TypeName PSObject -Property ([Ordered]@{
                        'Grantee'  = $sid
                        'Permission' = $lsp
                        'Granted'  = $priv
                })
            }
        }
        return $priviledges
    }
    end {
        # Remove the file
        Remove-Item $filename
    }
}
