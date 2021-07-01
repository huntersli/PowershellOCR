function Get-pdfs{
param (
       $pdflocation
    )
Write-host 'Testing PDF Location is accessable' 
If (Test-Path -Path $pdflocation){
   
Write-host 'PDF Location is accessable' 
Get-ChildItem -Path $pdflocation -Recurse -File | Where-Object {$_.Extension -eq ".pdf"}

}Else{

Write-Host 'Path is not avialable' 
}



}

###Global Variables

$global:pdffiles = Get-pdfs -pdflocation '\\finngeekfile003.finngeek.com\Personal\Shauns Documents\Personal\Bills and letters\Misc\'
$global:temppath = "C:\Temp\"

function ConvertPNG{
param (
        $pdf
        )

if (Test-Path -Path $global:temppath) {
    } else {
    Write-host Creating Temp Folder
    New-Item -ItemType directory -Path $global:temppath
}

    $magick = "magick.exe"
    $pngFile = Split-Path $pdf.Basename -leaf
	$pngFile = $pngFile + '.png'
    $pngFilePath = $global:temppath + $pngFile
    $argInput = '"' + $pdf.FullName + '"'
    $argOutpu = '"' + $pngFilePath + '"'
    $args = 'convert', '-density','150' + $argInput + $argOutpu


Write-Host 'Converting ....' + $argInput + 'to PNG'

& $magick $args 

ConverttoPDF  -originalpath $pdf.DirectoryName -oringalName $pdf.Name


}



function ConverttoPDF{
param (
       
       $originalpath,
       $oringalName,
       $pdf
    )

Write-Host 'Detecting Text and converting each PNG to PDF'    
Get-ChildItem -Path $global:temppath -Filter '*.png' | ForEach-Object {
Set-Location $global:temppath
Write-Host 'Detecting Text and making ....' + $_.Name + 'to OCRed PDF'
   & 'tesseract.exe' $_.Name ($_.BaseName) PDF
    
  }

Write-Host 'Merging All PDFS in Temp Folder'



$pdfext = '*.pdf'
$outputpdf = 'out.pdf'
$qpdfinputlocation = '"' + $global:temppath + $pdfext + '"'
$qpdfoutputlocation = '"' + $global:temppath + $outputpdf + '"'

& 'C:\qpdf\bin\qpdf.exe' --empty --pages $temppathargs -- $qpdfoutputlocation


$convertedpdf = Get-ChildItem -Path $global:temppath -Filter 'out.pdf'


$originalpath = $pdf.fullname
$movingLocation = $originalpath
$backupname = $pdf.Name + '.old'


Write-Host 'Renaming Orngial File - Location: ' $originalpath 
Rename-Item -Path $originalpath -NewName $backupname


Write-Host 'Moving Converted PDF to Orginal Location'
Move-Item -Path $convertedpdf.FullName -Destination $movingLocation

$removepath = $global:temppath + '*.*'
Write-Host 'remove unused Files'
Write-Host 'Removing Backup File'
Remove-Item $backupname
Write-Host 'Removing Temp Files'
Remove-Item $removepath
}


foreach ($pdf in $global:pdffiles) {
Write-Host 'Starting......'
Write-Host 'Working on' $pdf.Name

If ($pdf.Length -lt 25MB) {
write-host $pdf.Name 'Is the right size' 
write-host 'Converting PDF to PNG'
convertPNG -pdf $pdf 

}else {

write-host $pdf.Name 'is to big Skipping to next one' 

}





}
