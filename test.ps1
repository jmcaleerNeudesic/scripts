$path = Get-Location
#Declare the file path and sheet name
$file = "$path\avsinputs.xlsx"
$sheetName = "userinputs"
#Create an instance of Excel.Application and Open Excel file
$objExcel = New-Object -ComObject Excel.Application
$workbook = $objExcel.Workbooks.Open($file)
$sheet = $workbook.Worksheets.Item($sheetName)
$objExcel.Visible=$false
#Count max row
$rowMax = ($sheet.UsedRange.Rows).count
#Declare the starting positions
$rowsub,$colsub = 1,1
$rowrg,$colrg = 1,2
$rowregion,$colregion = 1,3
#loop to get values and store it
for ($i=1; $i -le $rowMax-1; $i++)
{
$sub = $sheet.Cells.Item($rowName+$i,$colName).text
$rg = $sheet.Cells.Item($rowAge+$i,$colAge).text
$region = $sheet.Cells.Item($rowCity+$i,$colCity).text

Write-Host ("Subscription: "+$sub)
Write-Host ("Resource Group: "+$rg)
Write-Host ("Region: "+$region)
}
#close excel file
$objExcel.quit()