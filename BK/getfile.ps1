$path='C:\wget\'
cd $path
wget ftp://10.119.237.248/VMinventory.zip -UsebasicParsing -outfile out.zip
if(test-path $path){
& 'C:\Program Files\7-Zip\7z' e out.zip
$filename = (Get-ChildItem|?{$_.name -like '*All*'}).name
Rename-item -path $path$filename -newname VMinventory.csv
Remove-item C:\inetpub\csv\*
Move-Item -path $path'VMinventory.csv' -destination C:\inetpub\csv
Remove-item $path*
}