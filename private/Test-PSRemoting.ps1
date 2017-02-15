#requires -version 3.0
 
Function Test-PSRemoting 
{
    <#
        .SYNOPSIS
        Purpose of "Test-PSRemoting" is to test WinRM.

        .DESCRIPTION
        The function submits an identification request that determines whether the WinRM service is running on a local or remote computer. 
        If the tested computer is running the service, the cmdlet displays the WS-Management identity schema, the protocol version, the product vendor, and the product version of the tested service. 

        .PARAMETER Computername
        Describe parameter -Computername.

        .PARAMETER Authentication
        Describe parameter -Authentication.

        .PARAMETER Credential
        Describe parameter -Credential.

        .EXAMPLE
        Test-PSRemoting -Computername Value -Authentication Value -Credential Value
        Describe what this call does

        .NOTES
        Place additional notes here.

        .LINK
        URLs to related sites
        The first link is opened by Get-Help -Online Test-PSRemoting

        .INPUTS
        List of input types that are accepted by this function.

        .OUTPUTS
        List of output types produced by this function.
    #>


    [cmdletbinding()]
 
    Param(
        [Parameter(Position = 0,Mandatory,HelpMessage = 'Enter a computername',ValueFromPipeline)]
        [ValidateNotNullorEmpty()]
        [string]$Computername,
        [Parameter(Position = 1)][string]$Authentication = 'default',    
        [System.Management.Automation.Credential()]$Credential = [pscredential]::Empty

    )
 
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"  
    } 
 
    Process {
        Write-Verbose -Message "Testing $Computername"
        Try 
        {
            Test-WSMan -ComputerName $Computername -Credential $Credential -Authentication $Authentication -ErrorAction Stop
            $True 
        }
        Catch 
        {
            Write-Error -Message $_.Exception.Message
            $False
        }
 
    } 
 
    End {
        Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"
    } 
}