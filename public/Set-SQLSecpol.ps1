#requires -Version 3.0
function Set-SQLSecpol 
{
    <#
            .SYNOPSIS
            This will grant all necessary privileges to the service account for a SQL service.

            .DESCRIPTION
            This will grant all necessary privileges to the service account for a SQL service.
            Following privileges will be granted:
            - Adjust memory quotas for a process
            - Bypass traverse checking
            - Log on as a service
            - Replace a process-level token
            - Perform volume maintenance tasks
            - Impersonate a client after authentication
            - Increase a process working set
            - Lock pages in memory
        
            .PARAMETER account
            This is the service account for a SQL service.
            If the account is a local account and no computer name is given then the computer name will be add in fron tof the account.

            .EXAMPLE
            Set-SQLSecpol -account domain\sql_svc

            .NOTES
            .LINK
            .INPUTS
            .OUTPUTS
    #>

 
    [cmdletbinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$account

    )

    Begin {
        if ([string]::IsNullOrEmpty($account.Split('\')[1]))
        {
            $server = $env:COMPUTERNAME
            $accountsvc = "$server\$account"
        }
        else 
        {
            $accountsvc = $account
        }
        
        $privs = ('SeIncreaseQuotaPrivilege', 'SeChangeNotifyPrivilege', 'SeServiceLogonRight', 'SeAssignPrimaryTokenPrivilege', 'seManageVolumePrivilege ', 'SeImpersonatePrivilege', 'SeIncreaseWorkingSetPrivilege', 'SeLockMemoryPrivilege')

        Write-Verbose -Message "Account: $($accountsvc)"
    }
    process { 


        $sidstr = $null
        try 
        {
            $ntprincipal = New-Object -TypeName System.Security.Principal.NTAccount -ArgumentList "$accountsvc"
            $sid = $ntprincipal.Translate([Security.Principal.SecurityIdentifier])
            $sidstr = $sid.Value.ToString()
        }
        catch 
        {
            $sidstr = $null
        }


        if( [string]::IsNullOrEmpty($sidstr) ) 
        {
            Write-Error -Message 'Account not found!'
            exit -1
        }

        Write-Verbose -Message "Account SID: $($sidstr)"
        Write-Verbose -Message 'Export current Local Security Policy'
        $tmp = [IO.Path]::GetTempFileName()
        $null = & "$env:windir\system32\secedit.exe" /export /cfg "$($tmp)" 
        $c = Get-Content -Path $tmp 

        foreach($priv in $privs) 
        {
            $currentSetting = ''

            foreach($s in $c) 
            {
                if( $s -like "$priv*") 
                {
                    $x = $s.split('=',[StringSplitOptions]::RemoveEmptyEntries)
                    $currentSetting = $x[1].Trim()
                }
            }

            if( $currentSetting -notlike "*$($sidstr)*" ) 
            {
                Write-Verbose -Message "Modify Setting ""$priv"""
	
                if( [string]::IsNullOrEmpty($currentSetting) ) 
                {
                    $currentSetting = "*$($sidstr)"
                }
                else 
                {
                    $currentSetting = "*$($sidstr),$($currentSetting)"
                }
	
                Write-Verbose -Message "$currentSetting"
	
                $outfile = 
@"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
$priv = $($currentSetting)
"@

                $tmp2 = [IO.Path]::GetTempFileName()
                $outfile | Set-Content -Path $tmp2 -Encoding Unicode -Force

                Push-Location -Path (Split-Path -Path $tmp2)

                try 
                {
                    Write-Verbose -Message 'Import new settings to Local Security Policy'
                    $null = & "$env:windir\system32\secedit.exe" /configure /db 'secedit.sdb' /cfg "$($tmp2)" /areas USER_RIGHTS 
                }
                finally 
                {
                    Pop-Location
                }
            } else 
            {
                Write-Verbose -Message "Account already in ""$priv"""
            }
        }
    }
    end {
        Write-Verbose -Message 'Local Security Policy updated.'
    }
}
