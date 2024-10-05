# Bug Summary: 
## Add-Type Failure in Programmatically Elevated PowerShell Process
```
Add-Type -ReferencedAssemblies $scriptAssembly -TypeDefinition $sourceCode -Language $language -IgnoreWarnings
# and
Start-Process powershell.exe -Credential $adminCredential
```
Running on `Microsoft Windows NT 10.0.20348.0`</br> `Windows Server Eval 2022 with the latest KB5042881`
```
PSVersion                      5.1.20348.558
PSEdition                      Desktop
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0...}
BuildVersion                   10.0.20348.558
CLRVersion                     4.0.30319.42000
WSManStackVersion              3.0
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
```

When executing the Add-Type command within an elevated PowerShell process that was initiated programmatically, the operation fails. The error messages typically relate to issues with file paths or an inability to locate necessary assemblies. Interestingly, the same code executes without issues when run directly in an administrative PowerShell window launched manually through the graphical user interface.

## Key Observations:
1. The problem manifests when using `Start-Process` to launch an elevated `PowerShell` session.
2. The Add-Type command functions correctly in a standard, non-elevated `PowerShell` session.
3. Error messages suggest complications with file path resolution or assembly reference issues.
4. It's crucial to note that the code successfully compiles and adds the type in the elevated `PowerShell` session started from gui with *run as Admin*.
![pwsh_screeen](https://github.com/antnn/is-it-pwsh-bug-qm/blob/main/pwsh_bug.png?raw=true)

## Note: This issue appears to be resolved in PowerShell Core version 7.4.5.
```
   $adminUserName = Get-LocalizedAdminAccountName
    $PWord = ConvertTo-SecureString -String $adminPassword -AsPlainText -Force
    $adminCredential = New-Object -TypeName System.Management.Automation.PSCredential `
        -ArgumentList $adminUserName, $PWord
    if (-not (Test-Administrator)) {
           Start-Process pwsh -Credential $adminCredential `
        -ArgumentList "-NoExit -ExecutionPolicy Bypass $PSCommandPath"
            return
    }
}
Start-ElevatedProcess
if (Test-Administrator) {
   & "C:\Users\IEUser\Documents\setup\promote-dc.ps1"
}
```
