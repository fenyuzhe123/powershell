Import-Module CiscoUcsPS
Set-UcsPowerToolConfiguration -SupportMultipleDefaultUcs 1
$username = "ucs-TAN\svc.ucsbackup"
$mypass = get-content "$((Get-Location).Path)\ucsfault.txt" | convertto-securestring
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $mypass
$Las1 = "uslas-c6296fi-01.active.tan"  # 10.119.96.21
$Las2 = "uslas-c6296fi-02.active.tan"  # 10.119.97.3
$Las3 = "uslas-c6296fi-03.active.tan"  # 10.119.98.3
$Las4 = "uslas-c6120fi-04.active.tan"  # 10.119.39.30
$Ash1 = "usash-c6296fi-01.active.tan"  # 10.74.240.13
$Tor1 = "cator-c6296fi-01.active.tan"  # 10.133.96.23
$Kel1 = "cakel-c6248fi-01.active.tan"  # 10.148.96.23
$xian = "10.107.121.13"
$All_UCS = @($Ash1,$Las1,$Las2,$Las3,$Las4,$Tor1,$Kel1,$xian) 
Connect-Ucs $All_UCS -Credential $cred
Get-UcsFault | Where-Object { ($_.Severity -ne 'cleared') -and ($_.Ack -ne 'yes') } | sort Ucs,lasttransition -Descending | select Ucs,lasttransition,severity,status,type,dn,descr | Out-GridView 
disconnect-ucs