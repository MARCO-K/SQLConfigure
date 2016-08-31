function Test-SqlInstanceOptimization([string]$InstanceName, [string]$OptimizationType)
{
    if($OptimizationType -eq "OLTP")
    {
        $result1 = Test-SqlInstanceParameter -InstanceName $InstanceName -StartupParameter '-T1117' 
        $result2 = Test-SqlInstanceParameter -InstanceName $InstanceName -StartupParameter '-T1118'

        if($result1 -and $result2)
        {
            Write-Verbose -Message "Settings storage optimization option '$($OptimizationType)' is already set."
            return $result1 -and $result2
        }
    }
    elseif($OptimizationType -eq "DW")
    {
        $result1 = Test-SqlInstanceParameter -InstanceName $InstanceName -StartupParameter '-T1117' 
        $result2 = Test-SqlInstanceParameter -InstanceName $InstanceName -StartupParameter '-T610'

        if($result1 -and $result2)
        {
            Write-Verbose -Message "Settings storage optimization option '$($OptimizationType)' is already set."
            return $result1 -and $result2
        }
    }
    elseif($OptimizationType -eq "GENERAL")
    {
        return $true
    }
    
    $false
}
