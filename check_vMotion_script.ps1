
$strMyVMHostNameToCheck = "awesx2101.active.tan"
$VMHost = Get-VMHost -Name $strMyVMHostNameToCheck
#$SourceVMs="d:\vmlist.txt"
$vmss = get-vmhost -Name "mwvhes0188.active.tan"|Get-VM
#$vmss=Get-Content -Path "F:\vmlist.txt"|Foreach-Object {Get-VM $_ }
$viewSI = Get-View "ServiceInstance"
$viewVmProvChecker = Get-View $viewSI.Content.VmProvisioningChecker
$result = @()
foreach ($VM in $vmss){
$vmname=Get-VM $VM
foreach ($vserver in $vmname)
{
$compaity=$viewVmProvChecker.QueryVMotionCompatibilityEx($vserver.Id, $VMHost.Id)
$row = "" | Select  VM,VMHost,Warning,Error
$row.VM = $vserver.name
$row.VMHost=$VMHost.name
$row.Warning=$compaity[0].Warning
$row.Error=$compaity[0].Error
#$row.Message=$row.Error[0].localizedmessage
$result += $row 
}
}
$result|Export-Csv -NoTypeInformation -Path "F:\VMdetails.csv"