<#
.Synopsis



.DESCRIPTION
Will create a scheduled task to reboot machines on Sunday at 2AM

.NOTES


#>



$ou = 'OU=Computers,DC=ADATUM,DC=COM'
$DaysInactive = 30
$time = (Get-Date).Adddays(-($DaysInactive))

#Use this to scan AD for PCs
#$computerNames = Get-ADComputer -SearchBase $ou -Filter {LastLogonTimeStamp -gt $time -and Name -like 'LON*'}  | select -ExpandProperty Name | Sort-Object

#Use this for a singular PC
$computerNames = "LON-SVR1"

#Use this for multipule computers
#$computerNames= Get-Content "c:\computers.txt"

$TaskName = "Force Restart"

$computerNames.Length

$count = 0
Foreach($comp in $computerNames)
    {
    If($comp -like "LON*")
        {
        if(Test-Connection -ComputerName $comp -Count 1 -Quiet)
            {
            Write-host -ForegroundColor Green "You are connected to $comp"
        
           }

    $count++
    $status = ($count/($computerNames.Length)) * 100
    Write-Host -ForegroundColor Green "$($status)%"
    }
    }

   
Invoke-Command -ComputerName $computerNames -Scriptblock {
        $action = New-ScheduledTaskAction -Execute "%SystemRoot%\system32\shutdown.exe" -Argument "/r /t 10 /f"
        $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am
        $principal = New-ScheduledTaskPrincipal -ID "Force Restart" -GroupId "Users"
        Register-ScheduledTask -TaskName "Force Restart" -Action $action -Trigger $trigger -Principal $principal -ErrorAction SilentlyContinue
        }
    