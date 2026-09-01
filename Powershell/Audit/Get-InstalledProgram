#This script is inteded to quickly audit for an installed program#

$Program= $env:program

Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$Program*" }
