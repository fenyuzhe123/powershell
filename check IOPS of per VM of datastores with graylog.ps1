#import source data
$start_date = get-date
$graylog = Get-Content d:\czhang4\Graylog.txt

Write-Host "Prepare Datastore info, waitng..........."

$lun_info = Get-Datacenter| ForEach-Object { Get-Cluster -Location $_ |ForEach-Object {
    Get-VMHost -Location $_ | select -First 1| get-view| ForEach-Object {$_.Config.StorageDevice.ScsiLun}|Select-Object DisplayName,CanonicalName,Model |Format-Table -AutoSize
    }
    } 
Write-Host $global:DefaultVIServer.Name "datastore info list is ready."
$end_date = Get-date
$runtime = ($end_date - $start_date).TotalSeconds
Write-host  "Running time:" $runtime "seconds"

$target_luns = @()
foreach($target_lun in $graylog){
    $target_lun -match "naa\..{32}"| Out-Null;
    $target_luns += $Matches[0]
    }
$target_luns_naa = $target_luns | Select-Object -Unique
Write-Host "Found IO latency warning message with these datastores" -ForegroundColor DarkCyan
$target_luns_naa

Write-Host "Warnig messages overview"
sleep 3
$regex = [regex]"aw.{18}|naa\..{32}|\d[0-9]*.microseconds|\d[0-9]*.mic[r]?[o]?[s]?[e]?[c]?[o]?[n]?[d]?[s]?|\btimestamp.{25}"
$log = @()
foreach($iolog in $graylog){
        $message = $regex.Matches($iolog)
        if ($message -ne $null){
            $log += $message[0].value +","+ $message[1].value + "," + $message[2].value+","+$message[3]+","+$message[4].value | Sort-Object $message[4].value
           
         }
    
    }
$log 


Write-Host "start to check  per VM IOPS realtime status of each datastore" 
sleep 3
$latencty_luns =""


$lun_info > d:\czhang4\lun_temp.txt
$aaa= Get-Content  d:\czhang4\lun_temp.txt 
foreach($row in $aaa)
{
$b =$row -replace '\s{1,}', ','

$b >>d:\czhang4\lun_temp1.txt
}

foreach($naa in $target_luns_naa){
import-csv -Path d:\czhang4\lun_temp1.txt  -Header a, b,c |sort -unique b |%{
if($naa -eq $_.b){
write-host "The VMs on " $_.a "are as below:"
Get-Datastore $_.a  -ErrorAction SilentlyContinue|  Get-vm | Where-Object {$_.PowerState -eq "PoweredOn"}|Sort| Select @{N="Name"; E={$_.Name}}, @{N="AvgWriteIOPS"; E={[math]::round((Get-Stat $_ -stat "datastore.numberWriteAveraged.average" -RealTime |Select -Expand Value | measure -average).Average, 1)}}, @{N="PeakWriteIOPS"; E={[math]::round((Get-Stat $_ -stat "datastore.numberWriteAveraged.average" -RealTime | Select -Expand Value | measure -max).maximum, 1)}}, @{N="AvgReadIOPS"; E={[math]::round((Get-Stat $_ -stat "datastore.numberReadAveraged.average" -RealTime | Select -Expand Value | measure -average).Average, 1)}}, @{N="PeakReadIOPS"; E={[math]::round((Get-Stat $_ -stat "datastore.numberReadAveraged.average" -RealTime | Select -Expand Value | measure -max).maximum, 1)}},@{N="ESXihost";E={$_.VMhost.Name}},@{N="Cluster";E={$_.VMhost.parent.Name}}| Format-Table -AutoSize
}
}
}

$end_date = Get-date
$runtime = ($end_date - $start_date).TotalSeconds
Write-host  "Running time:" $runtime "seconds"
Write-Host "Finished"
