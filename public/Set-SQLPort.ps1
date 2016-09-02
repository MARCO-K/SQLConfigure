<#
	.SYNOPSIS
		Set-SqlPort
	.DESCRIPTION
		Sets the SQL Server port configured for use using WMI
	.PARAMETER serverInstance
		This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
  .PARAMETER port
    This is the port number.
	.EXAMPLE
		.\Get-SqlPort -serverInstance Server01\sql2012
	.INPUTS
	.OUTPUTS
		SQL Server Port #
	.NOTES
		Use server name only to target default instance
	.LINK
#> 
function Set-SQLPort { 
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$ServerInstance,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateRange(1433,1450)][int]$port
    )
    Begin {
        $serverName = $serverInstance.Split('\')[0]
        $instance = $serverInstance.Split('\')[1]

        if ($instance -eq $null) {
            $instance = 'MSSQLSERVER'
        }
	
        $null = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
        $Server = New-Object Microsoft.SqlServer.Management.Smo.Server $serverInstance
        $ver = $Server.Information.VersionMajor
     
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
    
    Process { 
        try {
            $newport=Get-WmiObject -Namespace $WMInamespace -class ServerNetworkProtocolProperty -filter "PropertyName='TcpPort' and IPAddressName='IPAll' and Instancename='$Instance'" 
            $dynport=Get-WmiObject -Namespace $WMInamespace -class ServerNetworkProtocolProperty -filter "PropertyName='TcpDynamicPorts' and IPAddressName='IPAll' and Instancename='$Instance'" 
            $newPort.SetStringValue($port) | Out-Null
            $dynport.SetStringValue('') | Out-Null
            Write-verbose "Port changed to $Port - Service has to be restarted"
        }
        catch{
            Write-Error $Error[0]
            $err = $_.Exception
            while ( $err.InnerException ) {
                $err = $err.InnerException
                Write-Output $err.Message
            }
        }
    }
    end { Write-verbos -message "TCP port set to `"$port`" on `"$ServerInstance`"."  }
}