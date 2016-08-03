#requires -Version 3
function Add-SqlStartupParameter
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValuefromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
        [String]$serverInstance,
    [string[]]$StartupParameters)

    begin {}
    process 
    {
            $serverName = $ServerInstance.Split('\')[0]
            $instanceName = $ServerInstance.Split('\')[1]

            if ($instanceName -eq $null) 
            {
                $instanceName = 'MSSQLSERVER'
            } 

        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $serverName)

        $regKey = $reg.OpenSubKey('SOFTWARE\\Microsoft\\Microsoft SQL Server\\Instance Names\\SQL' )

        foreach($instance in $regKey.GetValueNames())
        {    
            if($instance -eq $InstanceName)
            { 
                $instanceRegName = $regKey.GetValue($instance)
            
                $parametersKey = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instanceRegName\MSSQLServer\Parameters"

                $props = (Get-Item $parametersKey).GetValueNames()

                $argNumber = $props.Count

                foreach($param in $StartupParameters)
                {
                    Write-Host -Object "Adding Startup Argument:$argNumber"

                    $newRegProp = 'SQLArg'+($argNumber) 
            
                    Set-ItemProperty -Path $parametersKey -Name $newRegProp -Value $param

                    $argNumber = $argNumber + 1
                }
            }
        }
    }
    end {}
}
