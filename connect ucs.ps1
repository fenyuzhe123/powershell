Add-PSSnapin VMware.VimAutomation.Core
$username = "TAN\czhang4"
$password = cat D:\poweshell\ps\securestring.txt | convertto-securestring
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
Connect-VIServer 10.107.100.50 -Credential $cred -NotDefault