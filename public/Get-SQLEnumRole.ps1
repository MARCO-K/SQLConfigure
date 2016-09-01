#requires -Version 3.0
function Get-SQLEnumRole
{
    <#
            .SYNOPSIS
            The function will enumerate all datase role granted to a login.

            .DESCRIPTION
            The function will enumerate all datase role granted to a login.

            .PARAMETER ServerInstance
            This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.

            .PARAMETER nosystem
            This switch controls if build-in logins and roles for system databases will be returned.

            .PARAMETER serverrole
            This switch controls if server-lervel roles will be returned.

            .EXAMPLE
            Get-SQLEnumRole -ServerInstance server\instance -nosystem -serverrole

            .NOTES
            .LINK
            .INPUTS
            .OUTPUTS
            Custom object with DB, login and role information.
    #>


    param (
        [Parameter(Mandatory,ValueFromPipeline)][string]$ServerInstance,
        [Parameter(ValueFromPipeline)][switch]$nosystem,
        [Parameter(ValueFromPipeline)][switch]$serverrole
    )
    
    begin {
        $null = [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
    }
    process {
        $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerInstance
        $serverName = $ServerInstance.Split('\')[0]


        if($nosystem) 
        {
            $logins = $server.Logins | Where-Object -FilterScript {
                $_.IsSystemObject -ne $true -and $_.Name -notlike '##*' -and $_.Name -notlike 'NT *' -and $_.Name -notlike "$serverName*" 
            }
            $databases = $server.Databases |Where-Object -FilterScript {
                $_.IsSystemObject -ne $true 
            }
        }
        else 
        {
            $logins = $server.Logins
            $databases = $server.Databases
        }
    
        try 
        {
            $logininfo = 
            foreach($login in $logins)    
            {
                $username = $login.Name

                if($serverrole) 
                {
                    foreach($role in $server.Roles)
                    {
                        $RoleMembers = $role.EnumMemberNames()
                                   
                        if($RoleMembers -contains $username)
                        {
                            New-Object -TypeName PSObject -Property ([Ordered]@{
                                    'Login'  = $login
                                    'Database' = '[server role]'
                                    'Role'   = $role
                            })
                        }
                    }
                }

                foreach($database in $databases)
                {
                    if($database.Users.Contains($username))  
                    {
                        #Write-Host "`n $servername , $database , $login "
                        foreach($role in $database.Roles)
                        {
                            $RoleMembers = $role.EnumMembers()
                                   
                            if($RoleMembers -contains $username)
                            {
                                #  Write-Host " $login is a member of $Role Role on $Database on $Server"
                                New-Object -TypeName PSObject -Property ([Ordered]@{
                                        'Login'  = $login
                                        'Database' = $database
                                        'Role'   = $role
                                })
                            }
                        }
                    }
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
    end {  
        $logininfo
        $server.ConnectionContext.Disconnect()
    
    }
}
                                
