<#
.SYNOPSIS

.DESCRIPTION
Checks reg path for allowing users to install pinter drivers.  If path doesn't exist it will create it, if it does exist it will set the proper reg value.

.NOTES

#>


## //---NOTE---\\ Use this one for specific computers. Change the location where the computer list is located. In the text file, list every computer per line.
## Make sure you comment out the other ComputersList above and below (#) Ex: #$ComputersList.
## Example:
##           MXL12345
##           MXL2365

#$ComputersList = Get-Content -Path "C:\computer.txt"

## //--- OR ---\\ =============================== //--- OR ---\\ =============================== //--- OR ---\\ =============================== //--- OR ---\\

## //---NOTE---\\ Single Computer Use. Make sure you comment out the other ComputersList above (#) Ex: #$ComputersList.
$ComputersList = "MXL2365"

#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

## Leave CompCount alone.
$CompCount = $ComputersList.Count

###############################################################################################################################################################
#---------- Functions ---------- Functions ---------- Functions ---------- Functions ---------- Functions ---------- Functions ---------- Functions ----------#
###############################################################################################################################################################

Function Test-RegistryValue
{

    [CmdletBinding()]

    param
            (
                $RegPath,
                $RegName
            )


    if(Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction Ignore)
        {
            $RegTest = $true
        }

    Else
        {
            $RegTest = $false
        }

    $RegTest
    
    Return $RegTest
}

###############################################################################################################################################################

Function Test-RegistryFolder
{

    [CmdletBinding()]

    param
            (
                $RegPath
            )

    $RegFolder = Test-Path -Path $RegPath

    Return $RegFolder
}

###############################################################################################################################################################
#----- END FUNCTION ----- END FUNCTION ----- END FUNCTION ----- END FUNCTION ----- END FUNCTION ----- END FUNCTION ----- END FUNCTION ----- END FUNCTION -----#
###############################################################################################################################################################


foreach ($Computer in $ComputersList)
{
    if(!(Test-Connection -ComputerName $Computer -Count 1 -Quiet))
        {
            $Connection = 'false'
            Write-Host -BackgroundColor Black -ForegroundColor Yellow "$Computer Is Offline"
        }

    else {
            $Connection = 'true'
            Write-Host -ForegroundColor Green "$Computer is Online"
            $Session = New-PSSession -ComputerName $Computer -ThrottleLimit 20 -ErrorAction SilentlyContinue
            $RegTest = Invoke-Command -Session $Session -ScriptBlock ${Function:Test-RegistryValue} -ArgumentList ($RegPath, $RegName)
            
            if ($RegTest -eq $True)
                {
                    Write-Host "Registry key already exist. Changing registry value."
                    Invoke-Command -Session $Session -ScriptBlock {
                    
                    $RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"
                    $RegName = "RestrictDriverInstallationToAdministrators"
                    $RegValue = 0
                    
                    ## Creates registry key within the folder.
                    Set-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue
                    Get-ItemProperty -Path $RegPath -Name $RegName}
                }

            else
                {
                    $RegFolder = Invoke-Command -Session $Session -ScriptBlock ${Function:Test-RegistryFolder} -ArgumentList ($RegPath)
                    
                    if ($RegFolder -eq $True)
                        {
                            Write-Host "Registry key does not exist. Creating registry key fix."
                            Invoke-Command -Session $Session -ScriptBlock {
                    
                            $RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"
                            $RegName = "RestrictDriverInstallationToAdministrators"
                            $RegProperty = "DWord"
                            $RegValue = 0

                            ## Creates registry key within the folder.
                            New-ItemProperty -Path $RegPath -Name $RegName -PropertyType $RegProperty -Value $RegValue
                            Get-ItemProperty -Path $RegPath -Name $RegName}
                        }
                    
                    else
                        {
                            Write-Host "PointAndPrint registry folder does not exist. Creating registry folder and keys."
                            Invoke-Command -Session $Session -ScriptBlock {

                            $RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"
                            $RegPath2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers"
                            $RegName = "RestrictDriverInstallationToAdministrators"
                            $RegProperty = "DWord"
                            $RegValue = 0

                            ## Creates a new folder in Registry.
                            New-Item -Path $RegPath2 -Name "PointAndPrint" -Force

                            ## Creates registry key within the folder.
                            New-ItemProperty -Path $RegPath -Name $RegName -PropertyType $RegProperty -Value $RegValue
                            Get-ItemProperty -Path $RegPath -Name $RegName}
                        }
                }
         }

    Write-Host "Disconnecting session...."
    Remove-PSSession -ComputerName $Computer -ErrorAction SilentlyContinue
}