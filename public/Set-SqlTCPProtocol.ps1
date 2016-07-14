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
function Set-SqlTCPProtocol { 
  param (
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$ServerInstance
  )

  begin {
    [void][reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
    [void][reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.SqlWmiManagement')
  }
  process {
    try {
      $wmi = new-object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer

      $server = $serverInstance.ToUpper().Split('\')[0]
      $instance = $serverInstance.ToUpper().Split('\')[1]

      if($instance -eq $null) {
        $instance = 'MSSQLSERVER'
      }

      $ProtocolUri = "ManagedComputer[@Name='" + $server + "']/ServerInstance[@Name='"+ $instance + "']/ServerProtocol"
      $tcp = $wmi.getsmoobject($ProtocolUri + "[@Name='Tcp']")

      # Enable the TCP protocol on the default instance.
      $Tcp.IsEnabled = $true
      $Tcp.Alter()
		
      return $Tcp
    }
    catch [Exception] {
      Write-Error $Error[0]
      $err = $_.Exception
      while ( $err.InnerException ) {
        $err = $err.InnerException
        Write-Output $err.Message
      }
    }
  }
  end { $message = "TCP porotcol enabled on `"$ServerInstance`".";  }
}
