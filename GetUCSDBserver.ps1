# Import Cisco UCS Module
Import-Module "C:\Program Files (x86)\Cisco\Cisco UCS PowerTool\Modules\CiscoUcsPS\CiscoUcsPS.psd1"

#Initialize variables for all our UCS Domains
$Las1 = "uslas-c6296fi-01.active.tan"  # 10.119.96.21
$Las2 = "uslas-c6296fi-02.active.tan"  # 10.119.97.3
$Las3 = "uslas-c6296fi-03.active.tan"  # 10.119.98.3
$Las4 = "uslas-c6120fi-04.active.tan"  # 10.119.39.30
$Ash1 = "usash-c6296fi-01.active.tan"  # 10.74.240.13
$Ash2 = "usash-c6120fi-03.active.tan"  # 10.79.56.26
$Ash3 = "usash-c6120fi-04.active.tan"  # 10.79.56.29
$Tor1 = "CATOR-C6296FI-01.active.tan"  # 10.133.96.23
$Kel1 = "CAKEL-C6248FI-01.active.tan"  # 10.148.96.23

$All_UCS = @($Ash1,$Ash2,$Ash3,$Las1,$Las2,$Las3,$Las4,$Tor1,$Kel1)
Set-UcsPowerToolConfiguration -SupportMultipleDefaultUcs 1
$ucs_handls = Connect-Ucs $All_UCS 

write-host "conneted all fi"

Get-UcsServiceProfile -ucs $ucs_handls