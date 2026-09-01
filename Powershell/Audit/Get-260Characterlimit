##This script is designed to check windows file paths for items greater than 260 characters, this character limit breaks many programs and processes, and this can be useful for diagnosing problem files.##

#specify directory to search under, such as "$env:USERPROFILE"
$dir=""

Get-ChildItem $dir -Recurse | ForEach-Object { if($.FullName.Length -gt 260){ "{0} = {1}" -f $.FullName, $_.FullName.Length}} | out-file -Filepath $env:USERPROFILE\Documents\260.txt ; gc $env:USERPROFILE\Documents\260.txt
