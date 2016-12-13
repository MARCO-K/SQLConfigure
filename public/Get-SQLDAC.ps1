function Get-SQLDAC
{
    #requires -Version 3.0
    <#
            .SYNOPSIS
            Get-SQLDAC
            .DESCRIPTION
            Get RemoteDacConnections value for a SQL Server instance
            .PARAMETER serverInstance
            This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
            .EXAMPLE
            Get-SQLDAC -serverInstance Server\Instance.
            .INPUTS
            .OUTPUTS
            integer value
            ConnectionString 
            .NOTES
            .LINK
    #>

    param (
        [Parameter(Mandatory,ValueFromPipeline)][string]$ServerInstance
    )

    begin {
        $null = [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
		
    }
    process {
        try 
        {
            Write-Verbose -Message 'Get SQL Server ConnectionString...'
            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerInstance
            $dac = $server.Configuration.RemoteDacConnectionsEnabled.RunValue
		
            return $dac
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
    end {
        $server.ConnectionContext.Disconnect()
    }
}
