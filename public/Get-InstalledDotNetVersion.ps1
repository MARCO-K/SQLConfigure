#requires -Version 3
<#
        .SYNOPSIS
        Shows all installed .Net versions.

        .DESCRIPTION
        Shows all .Net versions installed on server.

        .PARAMETER ComputerName
        The computer name or ip address to query, can be array.

        .EXAMPLE
        Get-InstalledDotNetVersions -ComputerNames server

        .OUTPUT
        Returns a custom object with .NET version information.

#>
function Get-InstalledDotNetVersion 
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0)][string[]]$ComputerNames
    )

    BEGIN {
    }

    PROCESS {


        foreach ($server in ($ComputerNames))
        {
            $dotNetVersionObjects += Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse |
            Get-ItemProperty -Name Version -EA 0 |
            Where-Object -FilterScript {
                $_.PSChildName -match '^(?![w,s])\p{L}'
            } |
            Select-Object -Property @{
                Name       = 'Computer Name'
                Expression = {
                    $server
                } 
            }, Version |
            Sort-Object -Property version -Unique
        }
    }

    END {
        Write-Output -InputObject $dotNetVersionObjects
    }
}
