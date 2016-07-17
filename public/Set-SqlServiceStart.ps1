#requires -Version 3
<#
        .SYNOPSIS
        Set-SqlServiceStart
        .DESCRIPTION
        Set service start mode for a SQL services.
        .PARAMETER serverInstance
        This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
        .PARAMETER services
        This paramter can be a service name.
        Allowed values are: 'sql','agent','anaylsis','report','browser'.
        .PARAMETER starttype
        This paramter defines the startup type for the service.
        Valid values are: 'Automatic','Manual','Disabled'
        .EXAMPLE
        Set-SqlServiceStart -serverInstance Server\Instance -service 'browser'
        .INPUTS
        .OUTPUTS
        .NOTES
        .LINK
#>
function Set-SqlServiceStart 
{
    param (
        [Parameter(Mandatory,ValueFromPipeline = $true)][string]$ServerInstance,
        [Parameter(Mandatory,ValueFromPipeline = $true)][ValidateSet('sql','agent','analysis','report','browser')][String]$service,
        [Parameter(Mandatory,ValueFromPipeline = $true)][ValidateSet('Automatic','Manual','Disabled')][String]$starttype
    )

    begin {
        $null = [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')

    }
    process {
        try 
        {
            Write-Verbose -Message "Set SQL service $service start mode..."
            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerInstance
            $serverName = $ServerInstance.Split('\')[0]
            $instance = $ServerInstance.Split('\')[1]

            if ($instance -eq $null) 
            {
                $instance = 'MSSQLSERVER'
            } 

            if($service) 
            {
                switch ($service)
                {
                    'agent' 
                    {
                        if ($instance -eq 'SQLSERVERAGENT') 
                        {
                            $searchstrg = $instance 
                        }
                        else 
                        {
                            $searchstrg = 'SQLAgent$' + $instance 
                        }
                    }
                    'analysis' 
                    {
                        if ($instance -eq 'MSOLAP') 
                        {
                            $searchstrg = $instance 
                        }
                        else 
                        {
                            $searchstrg = 'MSOLAP$' + $instance 
                        }
                    }
                    'report'  
                    {
                        if ($instance -eq 'ReportServer') 
                        {
                            $searchstrg = $instance 
                        }
                        else 
                        {
                            $searchstrg = 'ReportServer$' + $instance 
                        }
                    }
                    'sql'   
                    {
                        if ($instance -eq 'MSSQLSERVER') 
                        {
                            $searchstrg = $instance 
                        }
                        else 
                        {
                            $searchstrg = 'MSSQL$' + $instance 
                        }
                    }
                    'browser'  
                    {
                        $searchstrg = 'SQLBrowser'
                    }
                }

                $SqlService = (Get-Service | Where-Object -FilterScript {
                        $_.name -like $searchstrg
                }).Name




                if((Get-WmiObject -Class Win32_Service |
                        Where-Object -FilterScript {
                            $_.name -eq $SqlService
                        } |
                Select-Object -Property StartMode).StartMode.Replace('Auto','Automatic') -eq $starttype)
                {
                    Write-Verbose -Message "Service $SqlService is already set to startmode $starttype" 
                } 
                else 
                {
                    Set-Service -Name $SqlService -StartupType $starttype
                    Write-Verbose -Message "Service $SqlService set to startmode $starttype"
                }
            }
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
