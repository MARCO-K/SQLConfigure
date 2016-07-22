#requires -Version 3
<#
    .SYNOPSIS
    Displays the PowerScheme information on a server.
    .DESCRIPTION
    Returns a custom object for PowerScheme information on a server.
    .PARAMETER serverInstance
    This is the name of the source instance. 
    It's a mandatory parameter beause it is needed to retrieve the data.
    .EXAMPLE
    Get-PowerSchemes -serverInstance server
    .INPUTS
    .OUTPUTS
    Custom object with PowerScheme information (FriendlyName, ID, IsActive) 
    .NOTES
    .LINK
#>
function Get-PowerSchemes 
{
  [CmdletBinding()]
  Param (
    [parameter(Mandatory, ValueFromPipeline = $true)][string[]]$serverInstance
  )

  begin {

  }
  process {
    try 
    {
      # Get the currently active power scheme
      $CurrentScheme = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes | Select-Object -Property ActivePowerScheme
      # Get all the Power Schemes available on the machine
      $PowerSchemes = Get-ChildItem -Path HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes | ForEach-Object -Process {
        Get-ItemProperty -Path $_.pspath
      }
      
      # Loop through each of the Power Schemes to identify the friendly name of the currently active Power Scheme 
      $schema = 
      foreach ($Scheme in $PowerSchemes)
      {
        $schemename = ($Scheme.FriendlyName.Split(',').Trim())[2]
        $schemeid = $Scheme.PSChildName
        if($CurrentScheme.ActivePowerScheme -eq $schemeid) 
        {
          $isactive = $true
        }
        else 
        {
          $isactive = $false 
        }

        New-Object -TypeName PSObject -Property ([Ordered]@{
            'FriendlyName' = $schemename
            'ID'         = $schemeid
            'IsActive'   = $isactive
        })
      }

      $schema
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
}
