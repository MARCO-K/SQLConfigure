$serverInstance = 'sql1\s123'

    $null = [reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')

      $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $serverInstance
     $serverName = $serverInstance.Split('\')[0]


     $logins = $server.Logins | Where-Object { $_.IsSystemObject -ne $true -and $_.Name -notlike '##*' -and $_.Name -notlike "$servername*" }

     $logininfo =
      foreach($login in $logins)    {
      

       
                   $username = $login.Name




        foreach($database in $server.Databases)
        {
          if($database.Users.Contains($username))  {
                        #Write-Host "`n $servername , $database , $login "
                        foreach($role in $Database.Roles)
                                {
                                    $RoleMembers = $Role.EnumMembers()
                                   
                                        if($RoleMembers -contains $username)
                                        {
                                        #  Write-Host " $login is a member of $Role Role on $Database on $Server"
            New-Object -TypeName PSObject -Property ([Ordered]@{
                'Login'         = $login
                'Role'     = $Role
                'Database'    = $Database
            })

                                        }
                                      }
                   
 
                                    }
                                  }
                                }
                                $logininfo