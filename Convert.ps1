Clear
function Get-pdfs{
param (
       $pdflocation
    )
Write-Host $(Get-Date) 'Testing PDF Location is accessable' 
If (Test-Path -Path $pdflocation){
   
Write-Host $(Get-Date) 'PDF Location is accessable' 
Get-ChildItem -Path $pdflocation -Recurse -File | Where-Object {$_.Extension -eq ".pdf"}

}Else{

Write-Host $(Get-Date) 'Path is not avialable' 
}



}

###Global Variables

$global:pdffiles = Get-pdfs -pdflocation '\\UNC\SHARE'
$global:temppath = "C:\Temp\"

function ConvertPNG{
param (
        $pdf
        )

if (Test-Path -Path $global:temppath) {
    } else {
    Write-Host $(Get-Date) Creating Temp Folder
    New-Item -ItemType directory -Path $global:temppath
}

    $magick = "magick.exe"
    $pngFile = Split-Path $pdf.Basename -leaf
	$pngFile = $pngFile + '.png'
    $pngFilePath = $global:temppath + $pngFile
    $argInput = '"' + $pdf.FullName + '"'
    $argOutpu = '"' + $pngFilePath + '"'
    $args = 'convert', '-density','150' + $argInput + $argOutpu


Write-Host $(Get-Date) $(Get-Date) 'Converting ....' + $argInput + 'to PNG'

& $magick $args 

ConverttoPDF  -pdf $pdf


}



function ConverttoPDF{
param (
       
       $pdf
    )

Write-Host $(Get-Date) 'Detecting Text and converting each PNG to PDF'    
Get-ChildItem -Path $global:temppath -Filter '*.png' | ForEach-Object {
Set-Location $global:temppath
$teseractname = $_.Name
$teseractbasename = $_.BaseName
Write-Host $(Get-Date) 'Detecting Text and making ....' + $_.Name + 'to OCRed PDF'


$args = "-l eng PDF"
$teseractnameargs = '"' + $teseractname + '"'
$teseractnameargs2 = '"' + $teseractbasename + '"'
$teseractnameargs3 = "$args"




try {
   &'C:\Program Files\Tesseract-OCR\tesseract.exe'  $teseractnameargs $teseractnameargs2 PDF

} catch {

$string_err = $_ | Out-String

}


  }

Write-Host $(Get-Date) 'Merging All PDFS in Temp Folder'


$pdfext = '*.pdf'
$outputpdf = 'out.pdf'
$qpdfinputlocation = '"' + $global:temppath + $pdfext + '"'
$qpdfoutputlocation = '"' + $global:temppath + $outputpdf + '"'
$testpath = $global:temppath + $outputpdf

& 'C:\qpdf\bin\qpdf.exe' --empty --pages $qpdfinputlocation -- $qpdfoutputlocation

Start-Sleep -s 5
    If (Test-Path -Path $testpath ){
            $originalpath = $pdf.fullname
            $movingLocation = $pdf.fullname
            $backupname = $pdf.Name + '.old'


            Write-Host $(Get-Date) 'Renaming Orngial File - Location: ' + $pdf.fullname  
            #Rename-Item -Path $pdf.fullname -NewName $backupname

            Write-Host $(Get-Date) 'Moving Converted PDF to Orginal Location :' $convertedpdf.FullName
            Copy-Item -Path $testpath -Destination $movingLocation
            Write-Host $(Get-Date) 'Movning Location :' $movingLocation


            $removepath = $global:temppath + '*.*'
            Write-Host $(Get-Date) 'Removing unused Files'

           # Write-Host $(Get-Date) 'Removing Backup File'
           # $backupItem = Get-ChildItem -Path $pdf.DirectoryName -Recurse -File | Where-Object {$_.Extension -eq ".old"}
           # Remove-Item $backupItem.Name

            Write-Host $(Get-Date) 'Removing Temp Files'
            Remove-Item $removepath


}Else {

Write-Host 'Somethings Gone Wrong and qpdf has not outputted a file file or it cannot be found!' 

}


}

foreach ($pdf in $global:pdffiles) {
Write-Host $(Get-Date) 'Starting......'
Write-Host $(Get-Date) 'Working on' $pdf.Name

If ($pdf.Length -lt 25MB) {
Write-Host $(Get-Date) $pdf.Name 'Is the right size' 
Write-Host $(Get-Date) 'Converting PDF to PNG'
convertPNG -pdf $pdf 

}else {

Write-Host $(Get-Date) $pdf.Name 'is to big Skipping to next one' 

}





}
© 2021 GitHub, Inc.
Terms
Privacy
Security
Status
Docs
Contact GitHub
Pricing
API
Training
Blog
About
