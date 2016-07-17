#requires -Version 3
<#
        .SYNOPSIS
        Get-SqlDefaultFileLocations
        .DESCRIPTION
        Get default file locations for a SQL Server instance
        .PARAMETER serverInstance
        SQL Server instance
        .EXAMPLE
        .\Get-ISqlDefaultFileLocations -serverInstance Server\Instance
        .INPUTS
        .OUTPUTS
        Default file locations
        .NOTES
        .LINK
#>
function Get-SqlDefaultFileLocations 
{ 
    [cmdletbinding()]
    param([parameter(Mandatory = $true,ValueFromPipeline = $true)][string]$ServerInstance
    )

    begin {
        $null = [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
    }
    process {
        try 
        {
            Write-Verbose -Message 'Get SQL Server default file locations...'

            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerInstance

            $dataLoc = $server.Settings.DefaultFile
            $logLoc = $server.Settings.DefaultLog
            $backupLoc = $server.BackupDirectory
            
            if ($dataLoc.Length -eq 0) 
            {
                $dataLoc = $server.Information.MasterDBPath
            }
            if ($logLoc.Length -eq 0) 
            {
                $logLoc = $server.Information.MasterDBLogPath
            }

            $defaultLoc = New-Object -TypeName PSObject -Property @{
                DataPath  = $dataLoc
                LogPath   = $logLoc
                BackupLoc = $backupLoc
            }
            return $defaultLoc
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
