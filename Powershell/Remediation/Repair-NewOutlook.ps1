# Uses Reset-AppxPackage to reset user state of New Outlook

get-process *olk* | stop-process
try
{
Get-AppxPackage -Name "Microsoft.OutlookForWindows" | Reset-AppxPackage
write-host "Successful OLK reset"
exit 0
}
catch
{
  write-host "Something went wrong with the reset"
  exit 1
}
