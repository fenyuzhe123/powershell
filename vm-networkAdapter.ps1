$hosts= get-datacenter	'wcdc internal'|get-vmhost
$Report=@()
foreach($host1 in $hosts){

$VMs=$host1|get-vm 
foreach($vm in $VMs){
$row=""|select VMName,Status,VNIC,IP,PortGroup,VLANID,ConnectionState,VMhost
$row.VMName=$vm.name   #|Select-Object -Property  @{N="VMName";E={$_.parent}}
$row.VNIC=(get-NetworkAdapter $vm).name
$row.Status=$vm.powerstate
if
((get-networkadapter $vm).networkname -ne $null)
{
$row.IP=(get-view $vm).guest.ipaddress
$row.PortGroup=(get-NetworkAdapter $vm).networkname
$row.VLANID=(get-virtualportgroup -VMhost $host1 -name ((get-NetworkAdapter $vm).NetworkName)).VLanID
$row.ConnectionState=(get-NetworkAdapter $vm).connectionstate.connected
$row.VMhost=$vm.VMhost
$Report=$Report+$row
}
}
}

$Report|Export-Csv -NoTypeInformation c:\hfvm2_nic_info.csv
#Get-VM | Get-NetworkAdapter |Select-Object -Property  @{N="VMName";E={$_.parent}},@{N="VNIC";E={$_.Name}},NetworkName,@{N="VLANID";E={(Get-VirtualPortGroup -Name $_.NetworkName).VLanId}},@{N="ConnectionState";E={$_.connectionstate.connected}}|Export-Csv -NoTypeInformation c:\hfvm_nic_info.csv