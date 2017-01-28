$esxname ="awesx2102.active.tan"




get-vmhost $esxname | Get-Datastore |
Where-Object {$_.ExtensionData.Info.GetType().Name -eq "VmfsDatastoreInfo"} |
ForEach-Object {
  if ($_)
  {
    $Datastore = $_
    $Datastore.ExtensionData.Info.Vmfs.Extent |
      Where-Object {$_.DiskName -eq "naa.6006016013803600c06e7b141911e411"} |
      ForEach-Object {
        if ($_)
        {
          $Datastore
        }
      }
  }
}