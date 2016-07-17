#requires -Version 3
<#
        .SYNOPSIS
        Get-SqlLogfile
        .DESCRIPTION
        Get the number of logfiles for a SQL Server instance
        .PARAMETER serverInstance
        This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
        .EXAMPLE
        Get-SqlLogfile -serverInstance Server\Instance.
        .INPUTS
        .OUTPUTS
        ConnectionString 
        .NOTES
        .LINK
#>
function Get-SqlLogfile 
{
    param (
        [Parameter(Mandatory,ValueFromPipeline = $true)][string]$ServerInstance
    )

    begin {
        $null = [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
		
    }
    process {
        try 
        {
            Write-Verbose -Message 'Get number of SqlLogfiles ...'
            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerInstance
            $logfiles = $server.NumberOfLogFiles

            return $logfiles
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
