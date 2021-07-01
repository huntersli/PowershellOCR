$global:pdffiles = Get-pdfs -path '\\finngeekfile003.finngeek.com\Personal\Shauns Documents\'


function Get-pdfs{
param (
       $path
    )
Get-ChildItem -Path $path -Recurse -File

}



function Get-parentfolder{
param (
       $obj
           )
Write-Host 'Getting Parent Folder......'
$path = $obj.DirectoryName

}


function Get-PNG{
param (
        $pdf,
        $temppath
        )
Write-Host 'Test Temp Location....'

if (Test-Path -Path $temppath) {
    write-host "Path exists!"
} else {
    New-Item -ItemType directory -Path $temppath
}
    $magick = "magick.exe"
    $pngFile = Split-Path $pdf.Basename -leaf
	$pngFile = $pngFile + '.png'
    $pngFilePath = $temppath + $pngFile
    $temppathargs = '"' + $pdf.FullName + '"'
    $pngFilePathargs = '"' + $pngFilePath + '"'
    $args = 'convert', '-density','150' + $temppathargs + $pngFilePathargs


Write-Host 'Converting ....' + $pdf.FullName + 'TO PNG'

& $magick $args 

ConverttoPDF -path $temppath -originalpath $pdf.DirectoryName -oringalName $pdf.Name


}


function ConverttoPDF{
param (
       $path,
       $originalpath,
       $oringalName
    )

    
Get-ChildItem -Path $path -Filter '*.png' | ForEach-Object {
Set-Location $path
Write-Host 'Detecting Text and making ....' + $_.Name + 'to OCRed PDF'
   & 'tesseract.exe' $_.Name ($_.BaseName) out PDF
    
    
  }
Write-Host 'Merging All PDFS in Temp Folder'
$qpdf = 'C:\qpdf\bin\qpdf.exe'
$pdfext = '*.pdf'
$outoutpdf = 'out.pdf'
$temppathargs = '"' + $path + $pdfext + '"'
$temppathargs2 = '"' + $path + $outoutpdf + '"'

& 'C:\qpdf\bin\qpdf.exe' --empty --pages $temppathargs -- $temppathargs2
$output = Get-ChildItem -Path $path -Filter 'out.pdf'

$originalpath = $originalpath + '\' + $oringalName
$backupname = $oringalName + '.old'

Rename-Item -Path $originalpath -NewName $backupname
Write-Host 'Moving Converted PDF to Orginal Location'
Move-Item -Path $output.FullName -Destination $originalpath

$removepath = $path + '*.*'
Write-Host 'remove unused Files'
Remove-Item $backupname
Remove-Item $removepath
}



foreach ($pdf in $global:pdffiles) {
$temppath = "C:\Temp\"
Write-Host 'Starting......'

Get-parentfolder -obj $pdf
Get-PNG -pdf $pdf -temppath $temppath

}
