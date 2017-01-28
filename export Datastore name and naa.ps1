$datastore = get-datastore
$disks =get-vmhost -name "axesxcmpt0101.active.tan" | get-scsilun -luntype disk

$entry = @()
$output = @()
ForEach ($disk in $disks){
  $entry = "" | Select DataStorename, HostName, Canonicalname, Multipathing
  $entry.datastorename= $datastore | Where-Object {($_.extensiondata.info.vmfs.extent | %{$_.diskname}) -contains $disk.canonicalname}|select -expand name
  $entry.HostName = $disk.VMHost.Name
  $entry.canonicalname=$disk.canonicalname  
  $entry.multipathing=$disk.multipathpolicy
  $output += $entry
}
$output | Export-csv c:\lun_multipath.csv