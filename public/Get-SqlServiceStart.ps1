#requires -Version 3
<#
        .SYNOPSIS
        Get-SqlServiceStart
        .DESCRIPTION
        Get service start mode for the different SQL services.
        .PARAMETER serverInstance
        This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
        .PARAMETER services
        This paramter can be a single service or a list of services.
        Allowed values are: 'sql','agent','anaylsis','report','browser'.
        .EXAMPLE
        Get-SqlServiceStart -serverInstance Server\Instance -services 'sql','agent'
        .INPUTS
        .OUTPUTS
        SQL service object 
        .NOTES
        .LINK
#>
function Get-SqlServiceStart 
{
    param (
        [Parameter(Mandatory,ValueFromPipeline = $true)][string]$ServerInstance,
        [Parameter(Mandatory,ValueFromPipeline = $true)][ValidateSet('sql','agent','analysis','report','browser')][String[]]$services
    )

    begin {
        $null = [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
		
    }
    process {
        try 
        {
            Write-Verbose -Message 'Get SQL service start mode...'
            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerInstance
            $serverName = $ServerInstance.Split('\')[0]
            $instance = $ServerInstance.Split('\')[1]

            if ($instance -eq $null) 
            {
                $instance = 'MSSQLSERVER'
            } 

            $servicemode = 
            foreach ($service in $services) 
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

                $startmode = Get-WmiObject -Class Win32_Service -ComputerName $serverName |
                Where-Object -FilterScript {
                    $_.name -eq $SqlService
                } |
                Select-Object -Property Name, Displayname, StartMode, State, Startname

                New-Object -TypeName PSObject -Property ([Ordered]@{
                        'Name'         = $startmode.Name
                        'Displayname'  = $startmode.Displayname
                        'StartMode'    = $startmode.StartMode
                        'State'        = $startmode.State
                        'ServiceAccount' = $startmode.Startname
                })
            }
      
            return $servicemode
        }
        catch [Exception] 
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
