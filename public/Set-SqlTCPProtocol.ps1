#requires -Version 3
<#
        .SYNOPSIS
        Set-SqlTCPProtocol
        .DESCRIPTION
        Enables the TCP protocol
        .PARAMETER serverInstance
        This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
        .EXAMPLE
        .\Set-SqlTCPProtocol -serverInstance Server\Instance
        .INPUTS
        .OUTPUTS
        .NOTES
        .LINK
		
#>
function Set-SqlTCPProtocol 
{ 
    param (
        [parameter(Mandatory,ValueFromPipeline = $true)][string]$ServerInstance
    )

    begin {
        $null = [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
        $null = [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.SqlWmiManagement')
    }
    process {
        try 
        {
            $wmi = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer

            $server = $ServerInstance.ToUpper().Split('\')[0]
            $instance = $ServerInstance.ToUpper().Split('\')[1]

            if($instance -eq $null) 
            {
                $instance = 'MSSQLSERVER'
            }

            $ProtocolUri = "ManagedComputer[@Name='" + $server + "']/ServerInstance[@Name='"+ $instance + "']/ServerProtocol"
            $tcp = $wmi.getsmoobject($ProtocolUri + "[@Name='Tcp']")

            # Enable the TCP protocol on the default instance.
            $tcp.IsEnabled = $true
            $tcp.Alter()
		
            return $tcp
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
    end { $message = "TCP porotcol enabled on `"$ServerInstance`"."
    }
}
