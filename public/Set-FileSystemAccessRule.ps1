#requires -Version 3
<#
        .SYNOPSIS
        Set-FileSystemAccessRule
        .DESCRIPTION
        Set the ACL rule for a path.
        .PARAMETER path
        This is the path where to set the ACL rule. It's a mandatory parameter and the path must exist.
        .PARAMETER serviceaccounts
        This paramter is a list of service account to grant the ACL rule.
        More than one account can be used.
        .PARAMETER permission
        This paramter is the permission which will be granted.
        Allowed values are: 'Read', 'Write', 'ListDirectory', 'ReadandExecute', 'Modify', 'FullControl'.
        .PARAMETER noinherit
        This paramter is the InheritanceFlag.
        .PARAMETER containerinherit
        This paramter is the InheritanceFlag.
        .PARAMETER objectinherit
        This paramter is the InheritanceFlag.
        .PARAMETER deny
        This switch allows to allow or deny access.
        .EXAMPLE
        Set-FileSystemAccessRule -path 'C:\test' -serviceaccount 'domain\user' -permission FullControl -containerinherit
        .INPUTS
        .OUTPUTS
        .NOTES
        .LINK
#>
function Set-FileSystemAccessRule 
{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline = $true)][ValidateScript({
                    Test-Path -Path $_
        })][string]$path,
        [Parameter(Mandatory,ValueFromPipeline = $true)][string[]]$serviceaccounts,
        [Parameter(Mandatory,ValueFromPipeline = $true)][ValidateSet('Read', 'Write', 'ListDirectory', 'ReadandExecute', 'Modify', 'FullControl')][string]$permission,
        [Parameter(ParameterSetName = 'Noinherit')][switch]$noinherit,
        [Parameter(ParameterSetName = 'Container')][switch]$containerinherit,
        [Parameter(ParameterSetName = 'Object')][switch]$objectinherit,
        [switch]$deny
    )
    process { 
        foreach($serviceaccount in $serviceaccounts)
        {
            $rights = [System.Security.AccessControl.FileSystemRights]::$permission

            if ($containerinherit -OR $objectinherit) 
            {
                $propflag = [System.Security.AccessControl.PropagationFlags]::InheritOnly
            }
            else 
            {
                $propflag = [System.Security.AccessControl.PropagationFlags]::None
            }

 
            if ($containerinherit) 
            {
                $inhflag = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit
            }

            if ($objectinherit) 
            {
                $inhflag = [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
            }

            if ($noinherit) 
            {
                $inhflag = [System.Security.AccessControl.InheritanceFlags]::None
            }

            if ($deny) 
            {
                $type = [System.Security.AccessControl.AccessControlType]::Deny
            }
            else 
            {
                $type = [System.Security.AccessControl.AccessControlType]::Allow
            }
            $acr = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $serviceaccount, $rights, $inhflag, $propflag, $type

            try 
            { 
                $acl = Get-Acl -Path $path
                $acl.AddAccessRule($acr)
                Set-Acl -Path $path -AclObject $acl
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
}
