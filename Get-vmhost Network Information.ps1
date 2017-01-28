$vmhosts=Get-Content -Path c:\vmhost.txt
get-vmhost -name $vmhosts| Get-VMHostNetworkAdapter | select vmhost,Name,IP,SubnetMask,PortGroupName,vMotionEnabled |

Export-Csv -NoTypeInformation c:\Get-vmhost Network Information.csv