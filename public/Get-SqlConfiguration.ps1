<#
	.SYNOPSIS
	Get-SqlConfiguration
	.DESCRIPTION
	Get configuration for a SQL Server instance
    .PARAMETER serverInstance
    This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
	.PARAMETER filter
    The filter can be used the get only specified configuration values.
	If no filter is set then all values are returned.	
    .EXAMPLE
	Get-Get-SqlConfiguration -serverInstance Server\Instance
	.INPUTS
	.OUTPUTS
	Configuration Object
	.NOTES
	.LINK
#>
function Get-SqlConfiguration {
	param (
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$ServerInstance,
		[Parameter(ValueFromPipeline=$true)][string[]]$filter
		)

	begin {
		[void][reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
		$server = new-object Microsoft.SqlServer.Management.Smo.Server $serverInstance
		$SystemConfiguration = @()
		if($Filter){
			$configs = $server.Configuration | Get-Member -MemberType Properties | Where-Object {$Filter.Contains($_.Name)}
		}
		else{
			$configs = $server.Configuration | Get-Member -MemberType Properties | Where-Object {$_.Name -ne 'Properties'}
		}
	}
	process {
		try {
			Write-Verbose 'Get SQL Server configuration...'

			 foreach($config in $configs){
				 $SystemConfiguration += New-Object PSObject -Property ([Ordered]@{'Name'=$config.Name;
						 'RunValue'=$server.Configuration.$($config.Name).RunValue;
						 'ConfigValue' = $server.Configuration.$($config.Name).ConfigValue;
						 'IsDynamic' = $server.Configuration.$($config.Name).IsDynamic
				 })
			 }
			 return $SystemConfiguration
		}
		catch [Exception] {
			Write-Error $Error[0]
			$err = $_.Exception
			while ( $err.InnerException ) {
				$err = $err.InnerException
				Write-Output $err.Message
			}
		}
	}
}