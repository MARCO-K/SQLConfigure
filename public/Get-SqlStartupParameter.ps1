#requires -Version 3
function Get-SqlStartupParameter
{
  <#
      .SYNOPSIS
      Gets StartupParameters for a SQL instance.

      .DESCRIPTION
      This function will query the registry on a computer and return the StartupParameters for a SQL instance.

      .PARAMETER serverInstance
      This is the name of the source instance. 
      It's a mandatory parameter beause it is needed to retrieve the data.
      
      .OUTPUT
      Custom object with StartupParameters. 

      .EXAMPLE
      Get-SqlStartupParameter -serverInstance 'server\instance'
      .LINK
      .NOTES
  #>
  
  [CmdletBinding()]
  param(
    [Parameter(Mandatory,ValuefromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
  [String]$serverInstance)
    
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

      $props = Get-ItemProperty $parametersKey

      $params = $props.psobject.properties |
      Where-Object -FilterScript {
        $_.Name -like 'SQLArg*'
      } |
      Select-Object -Property Name, Value |
      Sort-Object -Property Name

      $params
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
  end { Write-Verbose -Message "SqlStartupParameter collected on `"$serverInstance`"." }
}
