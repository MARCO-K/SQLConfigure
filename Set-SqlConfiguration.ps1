function Set-SQLConfiguration 
{
#requires -Version 2.0
<#
    .SYNOPSIS
    Set configurationparamter for a SQL Server instance.
    .DESCRIPTION
    Set configurationparamter for a SQL Server instance. If restart is necessarry to apply the change it can restart the instance.
    .PARAMETER serverInstance
    This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
    .PARAMETER config
    This is the configuration parameter.
    .PARAMETER value
    This is the value for the configuration parameter.
    .PARAMETER restart
    If this parameter is $true and the configuration is nit dynamic then the server will be restartet.
    .EXAMPLE
    Set-SqlConfiguration -ServerInstance server\instance -config RemoteDacConnectionsEnabled -value 1 -Verbose
    .INPUTS
    .OUTPUTS
    Configuration object
    .NOTES
    .LINK
#>
  param (
    [Parameter(Mandatory,ValueFromPipeline)][string]$ServerInstance,
    [Parameter(Mandatory,ValueFromPipeline)][string]$config,
    [Parameter(Mandatory,ValueFromPipeline)]$value,
    [switch]$restart
		
  )

  begin {
    $null = [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
       

  }
  process {
    try 
    {
      $configs = ($server.Configuration | Get-Member -MemberType Properties).Name

      if($config -in $configs) 
      {
        if($server.Configuration.$config.ConfigValue -ne $value) 
        {
          Write-Verbose -Message "Changing configuration value from $($server.Configuration.$config.configvalue) to $value."
          $server.Configuration.$config.ConfigValue = $value
          $server.Configuration.Alter()
          if($server.Configuration.$config.IsDynamic -eq $true) 
          {
            Write-Verbose -Message 'Configuration option has been updated.'
          }  
          else 
          { 
            if($restart) 
            {
              Write-Verbose -Message 'SQL Service will be restarted'
              Stop-SQLService -ServerInstance $ServerInstance -services sql
              Start-SQLService -ServerInstance $ServerInstance -services sql
            }
            else 
            {
              Write-Verbose -Message 'Configuration option will be updated when SQL istance is restarted.'
            }
          }  
        }
        else 
        {
          Write-Verbose -Message "Configuration value for $config already set to $value."
        }
      }
      else 
      {
        Write-Verbose -Message "Configuration $config does not exist."
      }
      return $server.Configuration.$config
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
