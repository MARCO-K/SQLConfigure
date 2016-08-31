function Get-SQLPort 
{ 
  #requires -Version 3.0
  <#
      .SYNOPSIS
      Get-SqlPort
      .DESCRIPTION
      Retrieve SQL Server port configured for use using WMI
      .PARAMETER serverInstance
      This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
      .EXAMPLE
      Get-SQLPort -serverInstance Server\Instance
      .INPUTS
      .OUTPUTS
      SQL Server Port # and type
      .NOTES
      Use server name only to target default instance
      .LINK
  #> 

  [cmdletbinding()]
  param([parameter(Mandatory)][string]$ServerInstance
  )

  begin {
    $null = [Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
  }
  process {
    try 
    {
      Write-Verbose -Message 'Retrieve SQL Server port configured for use using WMI...'
            
      $smoServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerInstance
      $ver = $smoServer.Information.VersionMajor 
      $serverName = $ServerInstance.Split('\')[0]
      $instance = $ServerInstance.Split('\')[1]

      if ($instance -eq $null) 
      {
        $instance = 'MSSQLSERVER'
      } 

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

      # Create a WMI query
      $WQL = 'SELECT PropertyName, PropertyStrVal '
      $WQL += 'FROM ServerNetworkProtocolProperty '
      $WQL += "WHERE InstanceName = '" + $instance + "' AND "
      $WQL += "IPAddressName = 'IPall' AND "
      $WQL += "ProtocolName = 'Tcp'"

      Write-Debug -Message $WQL

      # Use PowerShell Get-WmiObject to run a WMI query 
      if ($isSQLSupported) 
      {
        $output = Get-WmiObject -Query $WQL -ComputerName $serverName -Namespace $WMInamespace | 
        Select-Object -Property PropertyName, @{
          Name       = 'Port'
          Expression = {
            $_.PropertyStrVal
          }
        }
      }
      else 
      {
        $output = 'SQL Server version is unsupported'
      }

      $output
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
  end { $server.ConnectionContext.Disconnect()
  }
}
