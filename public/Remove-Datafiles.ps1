#requires -Version 3.0
function Remove-Datafiles 
{
    <#
            .SYNOPSIS
            Describe purpose of "Drop-Datafiles" in 1-2 sentences.

            .DESCRIPTION
            Add a more complete description of what the function does.

            .PARAMETER ServerInstance
            Describe parameter -ServerInstance.

            .PARAMETER dbname
            Describe parameter -dbname.

            .EXAMPLE
            Drop-Datafiles -ServerInstance Value -dbname Value
            Describe what this call does

            .NOTES
            Place additional notes here.

            .LINK
            URLs to related sites
            The first link is opened by Get-Help -Online Drop-Datafiles

            .INPUTS
            List of input types that are accepted by this function.

            .OUTPUTS
            List of output types produced by this function.
    #>


    param( 
        [Parameter(Mandatory)][string]$ServerInstance,
        [Parameter(Mandatory)][string]$dbname 
    )
  
    begin {
        #Load assemblies
        #create initial SMO object
        $null = [Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
        $Server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerInstance
        
        $db = $Server.Databases[$dbname]
        $fg = $db.FileGroups['PRIMARY']
        $files = $fg.Files
    }
    process { 
        if($fg.Files.Count -gt 1) 
        { 
            for ($i = $fg.Files.Count ;$i -gt 1;$i -= 1)
            {
                $fileid = ($files | Measure-Object -Property ID -Maximum).Maximum
                $file = $files | Where-Object -FilterScript {
                    $_.ID -eq $fileid 
                }
            
                if ($fileid -gt 1) 
                {
                    Write-Debur $file
                    try 
                    {
                        Write-Verbose -Message "Shrinking file $($file.Name)"
                        $file.Shrink(0, [Microsoft.SqlServer.Management.Smo.ShrinkMethod]::EmptyFile)
                        $file.Refresh()
                    }
                    catch 
                    {
                        $ErrorMessage = $_.Exception.Message
                        wirte-error $ErrorMessage
                    }
                    try 
                    {
                        Write-Verbose -Message "Shrinking file $($file.Name)" 
                        $file.Drop()
                    }
                    catch 
                    {
                        $ErrorMessage = $_.Exception.Message
                        wirte-error $ErrorMessage
                    }
                }
                else 
                {
                    Write-Verbose -Message 'Primary datafile will not be deleted' 
                }
            }
        }
    }
    end {}
}
