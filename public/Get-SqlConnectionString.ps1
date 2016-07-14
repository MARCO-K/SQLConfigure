<#
	.SYNOPSIS
	Get-SqlConnectionString
	.DESCRIPTION
	Get ConnectionString for a SQL Server instance
    .PARAMETER serverInstance
    This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
    .EXAMPLE
    Get-SQLRecommendedMemory -serverInstance Server\Instance.
	.EXAMPLE
		.\Get-ISqlServerVersion -serverInstance Server\Instance
	.INPUTS
	.OUTPUTS
		ConnectionString 
	.NOTES
	.LINK
#>
function Get-SqlConnectionString {
	param (
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$ServerInstance
	)

	begin {
		[void][reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
		$server = new-object Microsoft.SqlServer.Management.Smo.Server $serverInstance
	}
	process {
		try {
			Write-Verbose 'Get SQL Server version...'

			$connection = $server.ConnectionContext.ConnectionString
		
			return $connection
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
