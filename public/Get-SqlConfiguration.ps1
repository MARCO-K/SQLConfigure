#requires -Version 3
<#
        .SYNOPSIS
        Get-SqlConfiguration
        .DESCRIPTION
        Get configuration for a SQL Server instance
        .PARAMETER serverInstance
        This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
        .PARAMETER filter
        The filter can be used the get only specified configuration values.
        If no filter is set then all values are returned.	
        .EXAMPLE
        Get-Get-SqlConfiguration -serverInstance Server\Instance
        .INPUTS
        .OUTPUTS
        Configuration Object
        .NOTES
        .LINK
#>
function Get-SqlConfiguration 
{
    param (
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)][string]$ServerInstance,
        [Parameter(ValueFromPipeline = $true)][string[]]$filter
    )

    begin {
        $null = [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')

    }
    process {
        try 
        {
            Write-Verbose -Message 'Get SQL Server configuration...'
            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerInstance
                    
            if($filter)
            {
                $configs = $server.Configuration |
                Get-Member -MemberType Properties |
                Where-Object -FilterScript {
                    $filter.Contains($_.Name)
                }
            }
            else
            {
                $configs = $server.Configuration |
                Get-Member -MemberType Properties |
                Where-Object -FilterScript {
                    $_.Name -ne 'Properties'
                }
            }

            $SystemConfiguration = 
            foreach($config in $configs)
            {
                New-Object -TypeName PSObject -Property ([Ordered]@{
                        'Name'      = $config.Name
                        'RunValue'  = $server.Configuration.$($config.Name).RunValue
                        'ConfigValue' = $server.Configuration.$($config.Name).ConfigValue
                        'IsDynamic' = $server.Configuration.$($config.Name).IsDynamic
                })
            }
            return $SystemConfiguration
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
