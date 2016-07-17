#requires -Version 3
<#
        .SYNOPSIS
        Get-SqlConnectionString
        .DESCRIPTION
        Get ConnectionString for a SQL Server instance
        .PARAMETER serverInstance
        This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
        .EXAMPLE
        Get-SQLRecommendedMemory -serverInstance Server\Instance.
        .INPUTS
        .OUTPUTS
        ConnectionString 
        .NOTES
        .LINK
#>
function Get-SqlConnectionString 
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
            Write-Verbose -Message 'Get SQL Server ConnectionString...'
            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerInstance
            $connection = $server.ConnectionContext.ConnectionString
		
            return $connection
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
