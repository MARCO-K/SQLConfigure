<#
	.SYNOPSIS
	Get-SqlVersion
	.DESCRIPTION
	Get version for SQL Server instance
    .PARAMETER serverInstance
    This is the name of the source instance. It's a mandatory parameter beause it is needed to retrieve the data.
    .EXAMPLE
    Get-SQLRecommendedMemory -serverInstance Server\Instance.
	.EXAMPLE
		.\Get-ISqlServerVersion -serverInstance Server\Instance
	.INPUTS
	.OUTPUTS
		Version Object
	.NOTES
	.LINK
#>
function Get-SQLVersion {
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

			$versionInfo = $server.Information.Version
		
			return $versionInfo
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
