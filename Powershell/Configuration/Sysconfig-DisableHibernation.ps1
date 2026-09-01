#Turn off hibernation at the registry level#
$Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
$Hibernation = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled").HiberbootEnabled

if ($Hibernation -eq 1){

 Set-ItemProperty -Path $path -Name HiberbootEnabled -Value 0 -Type DWord -Force -ErrorAction Stop
 
 #Turn off Hibernation at the power config level
  powercfg /h off
  
  Write-Host "Successfully disabled Fast Startup and Hibernation."
  }
  else {
    write-host "Hibernation is already $hibernation"
  }
