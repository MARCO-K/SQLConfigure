#requires -Version 3
  <#
      .SYNOPSIS
      Gets SqlTraceFlags for a SQL instance.
      .DESCRIPTION
      This function will query SqlTraceFlag information for a SQL instance.
      .PARAMETER serverInstance
      This is the name of the source instance. 
      It's a mandatory parameter beause it is needed to retrieve the data.
      
      .OUTPUT
      Custom object with SqlTraceFlag information. 
      .EXAMPLE
      Get-SqlTraceFlag -serverInstance 'server\instance'
      .LINK
      .NOTES
  #>
function Set-SqlTraceFlag
{
  
  [CmdletBinding()]
  param(
    [Parameter(Mandatory,ValuefromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$serverInstance,
    $traceflag=33226
    )
    
  begin {
      $null = [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
      }
  process  
  {
    Try 
    {
      #create an smo object for the SQL Server
      $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $serverInstance
      $traceflag
      $server.SetTraceFlag([int]$traceflag, $true)
            #create an smo object for the SQL Server
      Write-Verbose -Message "Get TaceFlags on `"$serverInstance`"."
      #get the trace flag status
      $TraceFlags = $server.EnumActiveGlobalTraceFlags()
 
      #loop through the trace flags and add the servername in order to create an object with all the required rows to import into a table later
      $traceinfo = 
      ForEach($TraceFlag in $TraceFlags)
      {
        Write-Verbose -Message "Information collected for TraceFlag `"$($TraceFlag.TraceFlag)`"."
        New-Object -TypeName PSObject -Property ([Ordered]@{
            'ServerName' = $server.Name
            'TraceFlag' = $TraceFlag.TraceFlag
            'Status'   = $TraceFlag.Status
            'Global'   = $TraceFlag.Global
            'Session'  = $TraceFlags.Session
        })
      }
      $traceinfo
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
  end { Write-Verbose -Message "TaceFlags collected on `"$serverInstance`"." }
}