#requires -Version 3
Function Get-PendingReboot
{
  <#
      .SYNOPSIS
      Gets the pending reboot status on  computer.

      .DESCRIPTION
      This function will query the registry on a  computer and determine if the
      system is pending a reboot.
      This reboot can be from Microsoft updates, Component-Based Servicing and Pending File Rename Operations. 

      .PARAMETER serverInstance
      This is the name of the source instance. 
      It's a mandatory parameter beause it is needed to retrieve the data.
      
      .OUTPUT
      Custom object with pending reboot information. 


      .EXAMPLE
      Get-PendingReboot -serverInstance 
      .LINK
      .NOTES
  #>

  [CmdletBinding()]
  param(
    [Parameter(Mandatory,ValuefromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
    [Alias('CN','Computer')]
    [String[]]$serverInstance
  )

  Begin {  }
  Process {
    $pendinginfo = 
    Foreach ($Computer in $serverInstance) 
    {
      Try 
      {
        $PendFileRename = $false
        $WUAUPending = $false
        $CBSPending = $null
						
        ## Querying WMI for build version
        $WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -Property BuildNumber, CSName -ComputerName $Computer -ErrorAction Stop

        ## Making registry connection to the local/remote computer
        $HKLM = [UInt32] '0x80000002'
        $WMI_Reg = [WMIClass] "\\$Computer\root\default:StdRegProv"
						
        ##query CBSRebootPending from the registry
        If ([Int32]$WMI_OS.BuildNumber -ge 6001) 
        {
          $RegSubKeysCBS = $WMI_Reg.EnumKey($HKLM,'SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\')
          $CBSPending = $RegSubKeysCBS.sNames -contains 'RebootPending'		
        }
							
        ## Query WUAU from the registry
        $RegWUAURebootReq = $WMI_Reg.EnumKey($HKLM,'SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\')
        $WUAUPending = $RegWUAURebootReq.sNames -contains 'RebootRequired'
						
        ## Query PendingFileRenameOperations from the registry
        $RegSubKeySM = $WMI_Reg.GetMultiStringValue($HKLM,'SYSTEM\CurrentControlSet\Control\Session Manager\','PendingFileRenameOperations')
        $RegValuePFRO = $RegSubKeySM.sValue

        If ($RegValuePFRO) 
        {
          $PendFileRename = $true
        }

    
        ## Creating Custom PSObject
        New-Object -TypeName PSObject -Property ([Ordered]@{
            Server        = $WMI_OS.CSName
            CBServicing   = $CBSPending
            WUAU          = $WUAUPending
            FileRename    = $PendFileRename
            RebootPending = ($CBSPending -or $WUAUPending -or $PendFileRename)
        }) 
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
    $pendinginfo |
    Sort-Object -Property server |
    Format-Table -AutoSize
  }

  End { 
    Write-Verbose -Message "Pending reboot information collected on `"$serverInstance`"."
  }
}
