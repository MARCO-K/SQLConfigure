#requires -Version 3.0 -Modules SQLConfigure
function Set-SQLPort 
{ 
  <#
      .SYNOPSIS
      Set-SqlPort

      .DESCRIPTION
      Sets the SQL Server port configured for use using WMI.

      .PARAMETER serverInstance
      This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.

      .PARAMETER port
      This is the port number.

      .PARAMETER restart
      This paramter controls if the instance will be restarted after the port change.

      .EXAMPLE
      .\Get-SqlPort -serverInstance Server01\sql2012

      .INPUTS
      .OUTPUTS
      .NOTES
      .LINK
  #> 

  [cmdletbinding()]
  param(
    [Parameter(Mandatory,ValueFromPipeline)][string]$ServerInstance,
    [Parameter(Mandatory,ValueFromPipeline)][ValidateRange(1433,1450)][int]$port,
    [Parameter(ValueFromPipeline)][switch]$restart = $false

  )
  Begin {

    $instance = $ServerInstance.Split('\')[1]

    if ($instance -eq $null) 
    {
      $instance = 'MSSQLSERVER'
    }
	
    $null = [Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
    $Server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerInstance
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
  }
  
  Process { 
    if($isSQLSupported) 
    { 
      try 
      {
        $newport = Get-WmiObject -Namespace $WMInamespace -Class ServerNetworkProtocolProperty -Filter "PropertyName='TcpPort' and IPAddressName='IPAll' and Instancename='$instance'" 
        $dynport = Get-WmiObject -Namespace $WMInamespace -Class ServerNetworkProtocolProperty -Filter "PropertyName='TcpDynamicPorts' and IPAddressName='IPAll' and Instancename='$instance'" 
        $null = $newport.SetStringValue($port)
        $null = $dynport.SetStringValue('')
        
        if($restart) 
        {
          Stop-SQLService -ServerInstance $ServerInstance -services 'sql'
          Start-SQLService -ServerInstance $ServerInstance -services 'sql'
          Write-Verbose -Message "Port changed to $port"
        }
        else 
        {
          Write-Verbose -Message "Port changed to $port - Service has to be restarted" 
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
    else 
    {
      Write-Verbose -Message 'Port changed not supported' 
    }
  }
  end { Write-Verbose -Message "TCP port set to `"$port`" on `"$ServerInstance`"."  }
}
