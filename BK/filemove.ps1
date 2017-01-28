$path1='C:\Program Files\7-Zip'

$path2='D:\jyang\Admin\pricing_module_files\logs'

$path3='C:\Program Files\7-Zip\VMinventory.zip'

$ftppath='D:\ftp\'

$a=dir $path2

$b=$a|?{$_.creationtime -gt (get-date).addDays(-1) -and $_.name -like '*all.csv'}

$string=$b[0].name

$csvpath=$path2+'\'+$string

cd $path1


.\7z a VMInventory.zip $csvpath

if(test-path $ftppath){ remove-item $ftppath*}

Move-Item -Path $path3   -Destination $ftppath