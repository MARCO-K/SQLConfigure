function Test-SqlStartupParameter
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory,ValuefromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$serverInstance,
    [string]$StartupParameter)

  begin {}
  process  
    {
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $env.ComputerName)

    $regKey= $reg.OpenSubKey("SOFTWARE\\Microsoft\\Microsoft SQL Server\\Instance Names\\SQL" )

    foreach($instance in $regkey.GetValueNames())
    {    
        if($instance -eq $InstanceName)
        { 
            $instanceRegName =  $regKey.GetValue($instance)

            $parametersKey = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instanceRegName\MSSQLServer\Parameters"

            $props = Get-ItemProperty $parametersKey

            $params = $props.psobject.properties | Where-Object{$_.Name -like 'SQLArg*'} | Select-Object Name, Value

            
            foreach ($param in $params)
            {
                if($param.Value -eq $StartupParameter)
                {
                    return $true
                }
            }
        }
    }

    $false;
}
}