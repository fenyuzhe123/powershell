Import-Module "C:\Program Files (x86)\Cisco\Cisco UCS PowerTool\Modules\CiscoUcsPS\CiscoUcsPS.psd1"
$username = "ucs-TAN\czhang4"
$password = cat D:\poweshell\ps\securestring.txt | convertto-securestring
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
$ucs_handls= Connect-Ucs 10.107.121.13 -Credential $cred -NotDefault