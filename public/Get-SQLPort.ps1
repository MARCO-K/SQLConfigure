#requires -Version 3
<#
        .SYNOPSIS
        Get-SqlPort
        .DESCRIPTION
        Retrieve SQL Server port configured for use using WMI
        .PARAMETER serverInstance
        This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
        .EXAMPLE
        Get-SqlPort -serverInstance Server\Instance
        .INPUTS
        .OUTPUTS
        SQL Server Port #
        .NOTES
        Use server name only to target default instance
        .LINK
#> 
function Get-SQLPort 
{ 
    [cmdletbinding()]
    param([parameter(Mandatory)][string]$ServerInstance
    )

    begin {
        $null = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
        
        #Create a WMI namespace for SQL Server
        $isSQLSupported = $false
        if ($ver -eq 9) 
        {
            $WMInamespace = 'root\Microsoft\SqlServer\ComputerManagement'
            $isSQLSupported = $true
        }
        else  
        {
            $WMInamespace = "root\Microsoft\SqlServer\ComputerManagement$ver"
            $isSQLSupported = $true
        } 
    }
    process {
        try 
        {
            Write-Verbose -Message 'Retrieve SQL Server port configured for use using WMI...'

            $serverName = $ServerInstance.Split('\')[0]
            $instance = $ServerInstance.Split('\')[1]

            if ($instance -eq $null) 
            {
                $instance = 'MSSQLSERVER'
            } 

            $smoServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerInstance
            $ver = $smoServer.Information.VersionMajor 

            # Create a WMI query
            $WQL = 'SELECT PropertyName, PropertyStrVal '
            $WQL += 'FROM ServerNetworkProtocolProperty '
            $WQL += "WHERE InstanceName = '" + $instance + "' AND "
            $WQL += "IPAddressName = 'IPAll' AND "
            $WQL += "ProtocolName = 'Tcp'"

            Write-Debug -Message $WQL

            # Use PowerShell Get-WmiObject to run a WMI query 
            if ($isSQLSupported) 
            {
                $output = Get-WmiObject -Query $WQL -ComputerName $serverName -Namespace $WMInamespace | 
                Select-Object -Property PropertyName, PropertyStrVal
            }
            else 
            {
                $output = 'SQL Server version is unsupported'
            }

            Write-Output -InputObject $output
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
    end { $message = "Getting port for `"$ServerInstance`"."
    }
}
