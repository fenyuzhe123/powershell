


get-vm | Where {$_.Powerstate -eq "poweredOn" -And $_.Guest.extensiondata.ToolsVersionStatus -eq "guestToolsNeedUpgrade"} | Select Name, @{N="Version";E={$_.Guest.extensiondata.ToolsVersion}}, @{N="Out of date";E={$_.Guest.extensiondata.ToolsVersionStatus}}|sort name| Export-Csv -path "C:\vmaaa-tools-tools.csv" -NoTypeInformation



