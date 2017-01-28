Import-Module CiscoUCSps
set-UcsPowerToolConfiguration -SupportMultipleDefaultUcs $true
# Define UCS connection details
$ucsdomain = ("10.107.121.13","uslas-c6296fi-01.active.tan","uslas-c6296fi-02.active.tan","uslas-c6296fi-03.active.tan","uslas-c6120fi-04.active.tan","usash-c6296fi-01.active.tan","cator-c6296fi-01.active.tan","cakel-c6248fi-01.active.tan")
#$ucsSysName1 = "uslas-c6296fi-01.active.tan"
#$ucsSysName2 = "uslas-c6296fi-02.active.tan"
#$ucsSysName3 = "uslas-c6296fi-03.active.tan"
#$ucsSysName4 = "uslas-c6120fi-04.active.tan"
#$ucsSysName5 = "usash-c6296fi-01.active.tan"
#$ucsSysName6 = "cator-c6296fi-01.active.tan"
#$ucsSysName7 = "cakel-c6248fi-01.active.tan"

#connect to UCS
$ucsUserName = "opsview"
$CredsFile = "c:\UCS\key\securestring.key"
$ucsPassword = Get-Content $CredsFile | ConvertTo-SecureString
 
#$ucsPassword = ConvertTo-SecureString -String $ucsPassword -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $ucsUserName, $ucsPassword
# Create connection to UCS system
#$ucsConnection = Connect-Ucs $ucsSysName -Credential $cred
#$ucsConnection = Connect-Ucs $ucsSysName1 -Credential $cred
#$ucsConnection = Connect-Ucs $ucsSysName2 -Credential $cred
#$ucsConnection = Connect-Ucs $ucsSysName3 -Credential $cred
#$ucsConnection = Connect-Ucs $ucsSysName4 -Credential $cred
#$ucsConnection = Connect-Ucs $ucsSysName5 -Credential $cred
#$ucsConnection = Connect-Ucs $ucsSysName6 -Credential $cred
#$ucsConnection = Connect-Ucs $ucsSysName7 -Credential $cred

#Syste date

$Date = Get-Date -Format "yyyy-MM-dd-HH-mm"


$Report = @()
foreach ($ucsSysName in $ucsdomain){
$ucsSysName
$ucsConnection = Connect-ucs $ucsSysName -Credential $cred
$allChassis = Get-UcsChassis
#$FI_ports= Get-UcsEtherSwitchIntFIo | Select-Object ChassisId,Discovery,Model,OperState,SwitchId,PeerSlotId,PeerPortId,SlotId,PortId,XcvrTyp
 $FI_ports= Get-UcsEtherSwitchIntFIo | Select-Object *
 
 foreach ($chassis in $allChassis)
        {
            Write-Progress -Activity "Analyzing Chassis $($chassis.Dn) of $($chassis.ucs)" `
                            -Status "Chassis $($allChassis.IndexOf($chassis)) of $($allChassis.Count)" `
                            -PercentComplete $(($allChassis.IndexOf($chassis) / $allChassis.Count)*100) `
                            -Id 1
            
            #--- Hash variable for storing current chassis data ---#
$chassisHash = @{}
$chassisHash.Dn = $chassis.Dn
$chassisHash.Id = $chassis.Id
$chassisHash.Model = $chassis.Model
$chassisHash.Status = $chassis.OperState
$chassisHash.Operability = $chassis.Operability
$chassisHash.Power = $chassis.Power
$chassisHash.Thermal = $chassis.Thermal
$chassisHash.Serial = $chassis.Serial
$chassisHash.Blades = $chassis| Get-UcsBlade
            $chassisHash.Adaptor = $chassisHash.Blades | Get-UcsAdaptorUnit
            $chassisHash.IOM = $chassis | get-ucsiom


            
            #Initial slot 

            $blades = $chassisHash.Blades.GetEnumerator() | select-object *
            
            $slotCount =0 

            while ($slotCount -lt $blades.Count) {
            $info = "" | select Ucs,chassis_ID,SlotId,chassis_SN,usrLbl,Serial,UUID,Model,mfgtime,Adaptor,IOM,CPU,NumOfCpus,NumOfCores,AvailableMemory,AssignedToDn
            $adaptor = get-ucsblade -dn $blades[$slotCount].dn |  Get-UcsAdaptorUnit
            $CPU = (get-ucsblade -dn $blades[$slotCount].dn|Get-UcsComputeBoard | Get-UcsProcessorUnit | Select-Object Model)[0].model
            #$adaptor_IOM = $adaptor | Get-UcsAdaptorExtEthIf | Select-Object PeerSlotId,PeerPortId
            #$adaptor_mac = $adaptor | Get-UcsAdaptorHostethIf |Select-Object Mac
            #$adaptor_wwn = $adaptor | Get-UcsAdaptorHostFcIf | Select-Object wwn 
            $info.ucs = $blades[$slotCount].ucs
            $info.chassis_ID = $chassisHash.Id
            $info.chassis_SN = $chassisHash.Serial
            $info.SlotId = $blades[$slotCount].SlotId
            $info.usrLbl = $blades[$slotCount].usrLbl
            $info.Serial = $blades[$slotCount].Serial
			$info.UUID = $blades[$slotCount].UUID
            $info.Model = $blades[$slotCount].Model
            $info.Adaptor = ($adaptor[0] | select Model).model
            $info.IOM = ($chassisHash.IOM).GetValue(0).Model
            #$info.MAC = $adaptor_mac
            #$info.wwn = $adaptor_wwn
            $info.cpu = $CPU
            $info.mfgtime = $blades[$slotCount].mfgtime
            $info.NumOfCpus =$blades[$slotCount].NumOfCpus
            $info.NumOfCores = $blades[$slotCount].NumofCores
            $info.AvailableMemory = $blades[$slotCount].AvailableMemory
            $info.AssignedToDn = $blades[$slotCount].AssignedToDn
            #$info.ConnPath = $blades[$slotCount].ConnPath
            $slotCount +=1
            $info
            $Report += $info
            }
            

}
Disconnect-Ucs
}

 
 
$Report | Export-Csv -Path C:\ucs\Report\UCSInventory.csv -NoTypeInformation






    