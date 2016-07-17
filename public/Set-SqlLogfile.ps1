#requires -Version 3
<#
        .SYNOPSIS
        Set-SqlLogfile
        .DESCRIPTION
        Set the number of logfiles for a SQL Server instance
        .PARAMETER serverInstance
        This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
        .PARAMETER
        This is the number of SQLLogfiles to be set.
        .EXAMPLE
        Set-SqlLogfile -serverInstance Server\Instance.
        .INPUTS
        .OUTPUTS
        ConnectionString 
        .NOTES
        .LINK
#>
function Set-SqlLogfile 
{
    param (
        [Parameter(Mandatory,ValueFromPipeline = $true)][string]$ServerInstance,
        [Parameter(Mandatory,ValueFromPipeline = $true)][int]$NumberOfLogFiles
    )

    begin {
        $null = [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
		
    }
    process {
        try 
        {
            Write-Verbose -Message "Set SQL Server NumberOfLogFiles $NumberOfLogFiles..."

            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerInstance
            if($server.NumberOfLogFiles -ne $NumberOfLogFiles) 
            {
                $server.NumberOfLogFiles = $NumberOfLogFiles  
                $server.Alter() 
                Write-Verbose -Message $("Number of errorlog files changed to $NumberOfLogFiles" ) 
                return $NumberOfLogFiles
            }
            else 
            {
                Write-Verbose -Message "Number of errorlog files already set to $NumberOfLogFiles" 
                return $NumberOfLogFiles
            }
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
