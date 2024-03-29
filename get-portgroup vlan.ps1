
$VLANInfo = foreach($cluster in Get-Cluster){

foreach($esx in (Get-VMHost -Location $cluster)){

foreach($pg in (Get-VirtualPortgroup -VMHost $esx -Standard | Where { $_.Name -NotMatch “-DVUplinks” })){
Select -InputObject $pg @{N=”Cluster”;E={$cluster.Name}},
@{N=”VMHost”;E={$esx.Name}},
@{N=”Portgroup”;E={$pg.Name}},
@{N=”VLAN”;E={$pg.VlanId}}
}
}
}

$VLANInfo | Select VMHost, PortGroup, VLAN | Export-CSV c:\vSphere-VLANs.csv
