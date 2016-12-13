#requires -Version 3.0
function Add-SqlStartupParameter
{
  <#
      .SYNOPSIS
      Adds a new StartupParameters for a SQL instance.

      .DESCRIPTION
      This function will add a new StartupParameter to the registry on a computer.

      .PARAMETER serverInstance
      This is the name of the source instance. 
      It's a mandatory parameter beause it is needed to retrieve the data.
      
      .PARAMETER StartParameters
      This is a list of paramter values which will be added. 
      It's a mandatory parameter.

      .OUTPUT
      Custom object with StartupParameters. 

      .EXAMPLE
      Add-SqlStartupParameter -serverInstance 'server\instance' -StartParameters '-T1118' -Verbose
      .LINK
      .NOTES
  #>
  
  [CmdletBinding()]
  param(
    [Parameter(Mandatory,ValuefromPipeline = $true,ValueFromPipelineByPropertyName = $true)][String]$serverInstance,
    [string[]]$StartParameters = ''
  )

  begin {
    $HKLM = 2147483650
    $reg = [wmiclass]'\\.\root\default:StdRegprov'
    $key = 'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL'
  }
  process 
  {
    try 
    { 
      $serverName = $serverInstance.Split('\')[0]
      $instanceName = $serverInstance.Split('\')[1]

      if ($instanceName -eq $null) 
      {
        $instanceName = 'MSSQLSERVER'
      } 

      $instanceRegName = $reg.GetStringValue($HKLM, $key, $instanceName).sValue

            
      $parametersKey = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instanceRegName\MSSQLServer\Parameters"

      $props = (Get-Item $parametersKey).GetValueNames()

      $argNr = $props.Count

     
      if($StartParameters) 
      { 
        foreach($parameter in $StartParameters)
        {
          $newKey = 'SQLArg'+($argNr) 
          Write-Verbose -Message "Adding StartupParameter $parameter"
          Set-ItemProperty -Path $parametersKey -Name $newKey -Value $parameter

          $argNr = $argNr + 1
        }
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
  end { Write-Verbose -Message "SqlStartupParameter collected on `"$serverInstance`"." }
}
