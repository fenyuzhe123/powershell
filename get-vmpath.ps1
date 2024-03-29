function Get-VMXPath { 
 
#Requires -Version 2.0 
[CmdletBinding()] 
 Param  
   ( 
    [Parameter(Mandatory=$true, 
               Position=1, 
               ValueFromPipeline=$true, 
               ValueFromPipelineByPropertyName=$true)] 
    [String[]]$Name    
   )#End Param  
 
Begin 
{ 
 Write-Verbose "Retrieving VMX Path Info . . ." 
}#Begin 
Process 
{ 
    try 
        { 
            $Name | ForEach-Object { 
            $VMView = Get-VM $_ -ErrorAction Stop | Get-View 
            $hash = @{ 
            VMPathName = $VMView.Config.Files.VmPathName 
            VMName     = $_ 
            } 
            New-Object psobject -Property $hash 
 
            } | Select-Object VmName,VMPathName 
        } 
    catch 
        { 
            "You must connect to VCenter first" | Out-host 
        } 
        
}#Process 
End 
{ 
 
}#End 
 
}#Get-VMXPath 

$VMs=Get-Content -path c:\vms.txt
$result = @()
foreach($vm in $VMs){
$output = ""|select Name,VMPathName,folder
$output.Name = (get-vm $VM).name
$output.VMPathName = ($vm|get-VMXPath).VMPathName
$output.folder = (get-vm $vm).folder.name
$result+=$output
}

$result|Export-Csv -NoTypeInformation C:\path10.csv 