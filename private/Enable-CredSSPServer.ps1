#requires -Version 2.0
function Enable-CredSSPServer
{
    <#
            .SYNOPSIS
            Enables and configures CredSSP Authentication to be used in PowerShell remoting sessions

            .DESCRIPTION
            Enabling CredSSP allows a caller from one remote session to authenticate on other remote 
            resources. This is known as credential delegation. By default, PowerShell sessions do not 
            use credSSP and therefore cannot bake a "second hop" to use other remote resources that 
            require their authentication token.

            Enable-CredSSPServer allows a computer to act as a delegate for another.
           
            .PARAMETER Computername
            A ComputerName to enable the CredSSP server role.
            If Computername is empty localhost will be used. 

            .OUTPUTS
            
            .EXAMPLE
            Enable-CredSSP srv1

    #>
    [CmdletBinding()]
    param(
        [string] $Computername = $env:COMPUTERNAME
    )

    if($Computername)
    {
        $FQDN = [Net.Dns]::GetHostByName(($Computername)) | Format-List -Property HostName | Out-String | ForEach-Object{ '{0}' -f $_.Split(':')[1].Trim() }
    }

    Write-Verbose -Message 'Configuring CredSSP settings...'
    $credssp = Get-WSManCredSSP

    $result = $credssp[1].IndexOf('is not ')

    if($result -gt -1)
    {
        try 
        {
            Write-Verbose -Message "Enabling CredSSP server role for $FQDN" -Verbose
            $null = Enable-WSManCredSSP -Role server -Force
        }
        catch 
        {
            Write-Error -Message "Enable-WSManCredSSP failed with: $_" -Verbose
            $false
        }
    }
    else
    {
        Write-Verbose -Message "CredSSP server role for $FQDN is already enabled" -Verbose
    }
}
