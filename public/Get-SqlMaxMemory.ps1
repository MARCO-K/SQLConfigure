#requires -Version 2
<#
        .SYNOPSIS
        Get-SqlMaxMemory
        .DESCRIPTION
        Get max memory property from SQL Server instance
        .PARAMETER serverInstance
        This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
        .EXAMPLE
        Get-SqlMaxMemory -serverInstance Server\Instance.
        .INPUTS
        .OUTPUTS
        Integer in MB 
        -1 if memory is set to default of 2GB	
        .NOTES
        .LINK
		
#>
function Get-SqlMaxMemory 
{
    param (
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)][string]$ServerInstance
    )

    begin {
        $null = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
    }
    process {
        try 
        {
            Write-Verbose -Message 'Get max memory property from SQL Server...'
            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerInstance

            $maxMemory = $server.Configuration.MaxServerMemory.ConfigValue
            if ($maxMemory -eq 2147483647) 
            {
                Write-Verbose -Message 'Max memory is set to unlimited'
                $maxMemory = -1
            }

            return $maxMemory
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
        end {
            $message = "Getting SqlMaxMemory for `"$ServerInstance`"."
        }
    }
}
