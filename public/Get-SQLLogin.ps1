#requires -Version 3.0
function Get-SQLLogin 
{
  <#
      .SYNOPSIS
      This function will return a list of loings for a SQL instance.

      .DESCRIPTION
      This function will return a list of loings for a SQL instance.

      .PARAMETER serverInstance
      This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.

      .PARAMETER nosystem
      This switch controls if build-in logins will be returned.

      .EXAMPLE
      Get-SQLLogin -serverInstance server\instance -nosystem

      .NOTES
      .LINK
      URLs to related sites

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      PSObject for lognins with properties.
  #>


  param(
    [Parameter(Mandatory,ValuefromPipeline,ValueFromPipelineByPropertyName)]
    [String]$serverInstance
  ,[switch]$nosystem)
    
  begin {
    $null = [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
  }
  process {
    try 
    {
      Write-Verbose -Message "Get login information on `"$serverInstance`"."
      $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $serverInstance
      $serverName = $serverInstance.Split('\')[0]

      $logins = $server.Logins
      $logininfo = 
      foreach($login in $logins) 
      {
        $username = $login.Name
        $userbase = ($username.Split('\')[0])

        if($nosystem) 
        {
          if(!($serverName -eq $userbase -or $username.StartsWith('##') -or $username -eq 'sa' -or $username.StartsWith('NT ')))
          {
            New-Object -TypeName PSObject -Property ([Ordered]@{
                'Login'         = $username
                'LoginType'     = $login.LoginType
                'IsDisabled'    = $login.IsDisabled
                'DefaultDatabase' = $login.DefaultDatabase
                'Language'      = $login.Language
            })
          }
        }
        else 
        {
          New-Object -TypeName PSObject -Property ([Ordered]@{
              'Login'         = $username
              'LoginType'     = $login.LoginType
              'IsDisabled'    = $login.IsDisabled
              'DefaultDatabase' = $login.DefaultDatabase
              'Language'      = $login.Language
          })
        }
      }
      $logininfo
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
