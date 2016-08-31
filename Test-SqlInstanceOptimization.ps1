#requires -Version 1.0
function Test-SqlInstanceOptimization
{
    <#
        .SYNOPSIS
        Describe purpose of "Test-SqlInstanceOptimization" in 1-2 sentences.

        .DESCRIPTION
        Add a more complete description of what the function does.

        .PARAMETER InstanceName
        Describe parameter -InstanceName.

        .PARAMETER OptimizationType
        Describe parameter -OptimizationType.

        .EXAMPLE
        Test-SqlInstanceOptimization -InstanceName Value -OptimizationType Value
        Describe what this call does

        .NOTES
        Place additional notes here.

        .LINK
        URLs to related sites
        The first link is opened by Get-Help -Online Test-SqlInstanceOptimization

        .INPUTS
        List of input types that are accepted by this function.

        .OUTPUTS
        List of output types produced by this function.
    #>


    
    param
    (
        [Parameter(Mandatory)]
        [string]
        $InstanceName,

        [Parameter(Mandatory)]
        [string]
        $OptimizationType
    )
if($OptimizationType -eq 'OLTP')
    {
        $result1 = Test-SqlInstanceParameter -InstanceName $InstanceName -StartupParameter '-T1117' 
        $result2 = Test-SqlInstanceParameter -InstanceName $InstanceName -StartupParameter '-T1118'

        if($result1 -and $result2)
        {
            Write-Verbose -Message "Settings storage optimization option '$($OptimizationType)' is already set."
            return $result1 -and $result2
        }
    }
    elseif($OptimizationType -eq 'DW')
    {
        $result1 = Test-SqlInstanceParameter -InstanceName $InstanceName -StartupParameter '-T1117' 
        $result2 = Test-SqlInstanceParameter -InstanceName $InstanceName -StartupParameter '-T610'

        if($result1 -and $result2)
        {
            Write-Verbose -Message "Settings storage optimization option '$($OptimizationType)' is already set."
            return $result1 -and $result2
        }
    }
    elseif($OptimizationType -eq 'GENERAL')
    {
        return $true
    }
    
    $false
}
