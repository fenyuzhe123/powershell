#$VM149=Get-Content -path c:\vms_149.txt
#$VM151=Get-Content -path c:\vms_151.txt
$VM156=Get-Content -path c:\vms_156.txt

#$folder149 = Get-Datacenter -name "WCDC NonProd"| Get-Folder "Perl - o1.m2.p149"|?{$_.type -eq "VM"}
#$folder151 = Get-Datacenter -name "WCDC Prod"| Get-Folder "dotNet - o1.m2.p151"|?{$_.type -eq "VM"}
$folder156 = Get-Datacenter -name "WCDC Prod"| Get-Folder "HF Utility Layer - o1.m2.p156"|?{$_.type -eq "VM"}



#foreach($vm1 in $VM149){

# Get-Datacenter -name "WCDC NonProd"| get-vm $vm1|Move-VM -Destination $folder149
#}

#foreach($vm2 in $VM151){

 #Get-Datacenter -name "WCDC Prod"| get-vm $vm2|Move-VM -Destination $folder151
#}

foreach($vm3 in $VM156){

 Get-Datacenter -name "WCDC Prod"| get-vm $vm3|Move-VM -Destination $folder156
}