#requires -Version 3
<#
        .SYNOPSIS
        Set-SqlConfiguration
        .DESCRIPTION
        Set configurationparamter for a SQL Server instance
        .PARAMETER serverInstance
        This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
        .PARAMETER config
        This is the configuration parameter.
        .PARAMETER value
        This is the value for the configuration parameter.
        .PARAMETER restart
        If this parameter is $true and the configuration is nit dynamic then the server will be restartet.
        .EXAMPLE
        Get-Get-SqlConfiguration -serverInstance Server\Instance
        .INPUTS
        .OUTPUTS
        Configuration Object
        .NOTES
        .LINK
#>
function Set-SqlConfiguration 
{
    param (
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)][string]$ServerInstance,
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)][string[]]$config,
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)]$value,
        [switch]$restart
		
    )

    begin {
        $null = [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
       

    }
    process {
        try 
        {
            Write-Verbose -Message "Set SQL Server configuration $config to $value"
            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerInstance
            
            $server.Configuration.$config.ConfigValue = $value 
            $server.Configuration.Alter()  
 
            if($server.Configuration.ShowAdvancedOptions.IsDynamic -eq $true) 
            {
                Write-Verbose -Message 'Configuration option has been updated.'
            }  
            else 
            { 
                if($restart) 
                {
                    Write-Verbose -Message 'Server will be restarted'
                    Stop-SQLService -ServerInstance $ServerInstance -services sql
                    Start-SQLService -ServerInstance $ServerInstance -services sql
                }
                else 
                {
                    Write-Verbose -Message 'Configuration option will be updated when SQL Server is restarted.'
                }
            }  

            return $server.Configuration.$config
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
