$report = @()
$vms = Get-VM | Get-View
foreach($vm in $vms){
     foreach($dev in $vm.Config.Hardware.Device){
          if(($dev.gettype()).Name -eq "VirtualDisk"){
               if(($dev.Backing.CompatibilityMode -eq "physicalMode") -or
               ($dev.Backing.CompatibilityMode -eq "virtualMode")){
                    $row = "" | select VMName, VMHost, HDDeviceName, HDFileName, HDMode, HDsize, HDDisplayName
                    $row.VMName = $vm.Name
                    $esx = Get-View $vm.Runtime.Host
                    $row.VMHost = ($esx).Name
                    $row.HDDeviceName = $dev.Backing.DeviceName
                    $row.HDFileName = $dev.Backing.FileName
                    $row.HDMode = $dev.Backing.CompatibilityMode
                    $row.HDSize = $dev.CapacityInKB
                    $row.HDDisplayName = ($esx.Config.StorageDevice.ScsiLun | where {$_.Uuid -eq $dev.Backing.LunUuid}).DisplayName
                    $report += $row
               }
          }
     }
}
$report|Export-CSV -notypeinformation "C:\GetRdmInfoByScanAll.CSV"