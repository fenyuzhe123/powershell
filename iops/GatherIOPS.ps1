################################################################################
# GatherIOPS v1.2
# by Curtis Salinas
# http://virtualcurtis.wordpress.com
# October 2010 
################################################################################
# 
# Given an array of datastore names, a vCenter Server FQDN,
# and a number of samples, this script will return a table
# of the read and write IOPS done by every virtual machine
# on those datastores over the sample interval. This data
# is output to the PowerShell screen and to a csv file
# called "IOPSReport.csv".
# 
# Example:
# GatherIOPS.ps1 -server myvcenterserver.mydns.com -datastores @("DS01") -numsamples 90
# 
# Returns:
# VM     Interval (minutes)         Avg Write IOPS            Avg Read IOPS
# --     ------------------         --------------            -------------
# VM01                   30       9.97194444444444            0.466111111111111
# VM01                   30       3.03222222222222            0.483888888888889
# VM01                   30                 8.7625            0.104444444444444
# VM01                   30       6.73638888888889            0.211111111111111
# VM01                   30       15.5652777777778            0.303055555555556
#
################################################################################


param($datastores, $server, $numsamples)

$username = read-host -prompt "Please enter local user account for host access"
read-host -prompt "Please enter password for host account" -assecurestring | convertfrom-securestring | out-file cred.txt
$password = get-content cred.txt | convertto-securestring
$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password


# add VMware PS snapin
if (-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) {
    Add-PSSnapin VMware.VimAutomation.Core
}

# connect vCenter server session
Connect-VIServer $server -NotDefault -WarningAction SilentlyContinue | Out-Null


# function to get iops for a vm on a particular host
function GetAvgStat($vmhost,$vm,$ds,$samples,$stat){
	# number of samples = x time
	# 180 = 60min
	# 90 = 30min
	# 45 = 15min
	# 15 = 5min
	# 3 = 1min
	# 1 = 20sec (.33 min)

	# connect to host
	connect-viserver -server $vmhost -credential $credentials -NotDefault -WarningAction SilentlyContinue | Out-Null
	
	# identify device id for datastore
	$myDatastoreID = ((Get-Datastore $ds -server $vmhost) | Get-View).info.vmfs.extent[0].diskname
	
	# gather iops generated by vm
	$rawVMStats = get-stat -entity	(get-vm $vm -server $vmhost) -stat $stat -maxSamples $samples
	$results = @()
	
	foreach ($stat in $rawVMStats) {
		if ($stat.instance.Equals($myDatastoreID)) {
			$results += $stat.Value
		}
	}
	
	$totalIOPS = 0
	foreach ($res in $results) {
		$totalIOPS += $res	
	}
	
	return [int] ($totalIOPS/$samples/20)
}

$IOPSReport = @()

foreach ($datastore in $datastores) {

  # Grab datastore and find VMs on that datastore
  $myDatastore = Get-Datastore -Name $datastore -server $server
  $myVMs = Get-VM -Datastore $myDatastore -server $server | Where {$_.PowerState -eq "PoweredOn"}
  
  # Gather current IO snapshot for each VM
  $dataArray = @()
  foreach ($vm in $myVMs) {
  	$data = �� | Select "VM", "Interval (minutes)", "Avg Write IOPS", "Avg Read IOPS"
  	$data."VM" = $vm.name
  	$data."Interval (minutes)" = ($numsamples*20)/60
  	$data."Avg Write IOPS" = GetAvgStat -vmhost $vm.host.name -vm $vm.name -ds $datastore -samples $numsamples -stat disk.numberWrite.summation
  	$data."Avg Read IOPS" = GetAvgStat -vmhost $vm.host.name -vm $vm.name -ds $datastore -samples $numsamples -stat disk.numberRead.summation
  	$dataArray += $data
  }
  
  # Do something with the array of data
  $IOPSReport += $dataArray

}

$IOPSReport
$IOPSReport | Export-CSV IOPSReport.csv -NoType