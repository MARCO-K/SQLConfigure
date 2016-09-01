function Test-SQLStartupParameter
{
  #requires -Version 3.0
  <#
      .SYNOPSIS
      Test a StartupParameter for a SQL instance.

      .DESCRIPTION
      This function will test if a given StartupParameters for a SQL instance is set in registry.

      .PARAMETER serverInstance
      This is the name of the source instance. 
      It's a mandatory parameter beause it is needed to retrieve the data.
      
      .PARAMETER startparameter
      This is paramter value which will be tested. 
      It's a mandatory parameter besause it is needed to retrieve the data.
      
      .OUTPUT
      True or false if startparamter exists. 

      .EXAMPLE
      Get-SqlStartupParameter -serverInstance 'server\instance'
      .LINK
      .NOTES
  #>
  
  param(
    [Parameter(Mandatory,ValuefromPipeline,ValueFromPipelineByPropertyName)]
    [String]$serverInstance,
    [Parameter(Mandatory, ValuefromPipeline, ValueFromPipelineByPropertyName)][string]$startparameter
  )
    
  begin {
    $HKLM = 2147483650
    $reg = [wmiclass]'\\.\root\default:StdRegprov'
    $key = 'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL'
  }
  process  
  {
    Try 
    {
      $serverName = $serverInstance.Split('\')[0]
      $instanceName = $serverInstance.Split('\')[1]

      if ($instanceName -eq $null) 
      {
        $instanceName = 'MSSQLSERVER'
      }
      $instanceRegName = $reg.GetStringValue($HKLM, $key, $instanceName).sValue


      $parametersKey = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instanceRegName\MSSQLServer\Parameters"

      $props = Get-ItemProperty -Path $parametersKey

      $params = $props.psobject.properties |
      Where-Object -FilterScript {
        $_.Name -like 'SQLArg*'
      } |
      Select-Object -Property Name, Value |
      Sort-Object -Property Name

      if ($params.Value -contains $startparameter)
      {
        return $true
      }
      else 
      {
        return $false
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
  end {
    Write-Verbose -Message "SqlStartupParameter collected on `"$serverInstance`"." 
  }
}
