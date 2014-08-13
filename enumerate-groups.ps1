import-module activedirectory

## Consider changing this into a hash table of OU_Name and DN_Prefix for each department of interest.
## Alternatively, set a $Root_OU variable to serve as the top of a search structure and generalize
## the entire thing using a Get-ADOrganizationalUnit -Filter * -SearchBase $Root_OU call.

# Expand this array to include more departments within SPH.
# Subgroups of departments are handled by making a multidimensional array entry.
$departments = @(
					"ADM", 
					"BIO", 
					"EHS",
					"EPID",
						# @(
							# "CSEPH"
						# ),
					"HBHE",
						# @(
							# "PRC",
							# "CMHD"
						# ),
					"HMP", 
					"ICS"
				)

Foreach( $department in $departments ){
	# Create individual output files for each department
	$OutFile = [environment]::getfolderpath("mydocuments") + "\enum-groups-$department.txt"

	if (Test-Path $OutFile) {
		Remove-Item $OutFile
	}
	
	# Get AD Groups under department OU
	$groups = Get-ADGroup -Properties * -Filter * -SearchBase "ou=$department,ou=Departments,OU=SPH,OU=Organizations,OU=UMICH,DC=adsroot,DC=itcs,DC=umich,DC=edu" | sort name

	# Output formatted member list for each AD Group
	Foreach( $group In $groups ){
		$group_name_header = $group.Name + "`n-------------"
		Add-Content -value $group_name_header -Path $OutFile
		
		$members = Get-ADGroupMember -Identity $group.SID | sort name | % { $_.Name.split(",")[0] }
		
		foreach( $member in $members) {
			Add-Content -Value $member -Path $OutFile
		}
		
		Add-Content -value "`n" -Path $OutFile
	}
}
