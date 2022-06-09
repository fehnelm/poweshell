<#
.Synopsis



.DESCRIPTION
Pulls all Security Groups within your Forest and Exports the following details to a CSV: Name, CN, Description, Number of Members, and Group Scope.

.NOTES
Author - Mikki Fehnel

Script Version: 1.0
#>

$SecurityGroups = Get-ADGroup -Filter 'GroupCategory -eq "Security"'-SearchBase 'DC=Adatum,DC=com'`
-Properties Name,Members,GroupCategory | Sort -Property Name
$count = 0
$groupCount = $ResearchGroups.Count

Write-Host -ForegroundColor Green "Gathering Data on Groups..."

$output = Foreach($group in $SecurityGroups)
    {

    $numberOfMember = (Get-ADGroup -Identity $group.DistinguishedName -Properties Members).members.count
    $groupDetails =[PSCustomObject]@{
    Name = $group.Name
    CN = $group.DistinguishedName
    Description = $group.Description
    "Number of Members" = $numberOfMember
    "Group Scope"= $group.GroupScope
            }
    $count++
  
$groupDetails|Export-Csv -Path C:\Temp\SecurityGroup.csv -NoTypeInformation -Append    
    }
