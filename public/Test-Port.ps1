#requires -Version 3
function Test-Port 
{
    <#
            .SYNOPSIS
            Test ports on computer
            .DESCRIPTION
            Test TCP or UDP ports on computer.
            .PARAMETER ComputerName
            The computer name or ip address to query, can be array.
            .PARAMETER Port
            Integer value of port to test, can be array.
            .PARAMETER Protocol
            Test TCP or UDP protocol.
            .EXAMPLE
            Test-Port localhost
            Checks if TCP port 135 open on localhost
            .EXAMPLE
            "Server" | Test-Port
            Checks if TCP port 135 open on Server
            .EXAMPLE
            Test-Port -ComputerName "Server1","Server2" -Port 80,21 -TCP
            Checks if TCP ports 80 and 21 are open on Server1 and Server2
            .OUTPUT
            Returns a custom object with connection information.

    #>
	
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0)][string[]]$ComputerName,
        [int[]]$Ports = 135,
        [ValidateSet('TCP','UDP')][String] $protocol = 'TCP'
    )
	
    begin {
		
    }

    process {

        foreach ($computer in $ComputerName) 
        {
            foreach ($Port in $Ports) 
            {
                if ($computer, "Testing port $Port")
                {
                    #Create return object
                    $returnobj = New-Object -TypeName psobject | Select-Object -Property ComputerName, Port, Connected
                    $returnobj.ComputerName = $computer
                    $returnobj.Port = $Port
                    Write-Verbose -Message "Processing $computer $protocol"
                    $sock = New-Object -TypeName System.Net.Sockets.Socket -ArgumentList $([Net.Sockets.AddressFamily]::InterNetwork), $([Net.Sockets.SocketType]::Stream), $([Net.Sockets.ProtocolType]::$protocol)

                    try 
                    {
                        Write-Verbose -Message "Open socket to $Port"
                        $sock.Connect($computer,$Port)
                        Write-Verbose -Message 'Returning Connection Status'
                        $returnobj.connected = $sock.Connected
                        $sock.Close()
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
                        $returnobj.connected = $false
                    }
                }
					
                    
                $returnobj
            }
        }
    }
}

