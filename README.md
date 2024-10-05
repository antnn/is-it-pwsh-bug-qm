[Also See below](https://github.com/antnn/is-it-pwsh-bug-qm/tree/main?tab=readme-ov-file#additional-findings)
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
### Note: This issue appears to be resolved in PowerShell Core version 7.4.5.

## Description:
When executing the Add-Type command within an elevated PowerShell process that was initiated programmatically, the operation fails. The error messages typically relate to issues with file paths or an inability to locate necessary assemblies. Interestingly, the same code executes without issues when run directly in an administrative PowerShell window launched manually through the graphical user interface.

## Key Observations:
1. The problem manifests when using `Start-Process` to launch an elevated `PowerShell` session.
2. The Add-Type command functions correctly in a standard, non-elevated `PowerShell` session.
3. Error messages suggest complications with file path resolution or assembly reference issues.
4. It's crucial to note that the code successfully compiles and adds the type in the elevated `PowerShell` session started from gui with *run as Admin*.
![pwsh_screeen](https://github.com/antnn/is-it-pwsh-bug-qm/blob/main/pwsh_bug.png?raw=true)

# Additional Findings:
When running PowerShell 7.4 (pwsh) with a [.\start.ps1](https://github.com/antnn/win-setup-action-ansible/blob/c6cbfe42ba5d0d78c285a8abd776ccbd4b39c5c8/action_plugins/templates/start.ps1#L20) similar to the one in the repository (using `Start-Process` with credentials), a different but potentially related issue occurs. Specifically, when calling `ConvertTo-SecureString` inside the child `PowerShell` process during a [domain controller promotion](https://github.com/microsoft/WindowsProtocolTestSuites/blob/797a4fa636a8eb0676f345950e2dddf2c394394e/CommonScripts/PromoteDomainController.ps1#L45), the following error is encountered:
```
Error happeded while executing PromoteDomainController.ps1:The 'ConvertTo-SecureString' command was found in the
module 'Microsoft.PowerShell.Security', but the module could not be loaded. For more information, run 'Import-Module
Microsoft.PowerShell.Security'.
At E:\toinstall\promote-domain-controller.ps1:79 char:9
+         throw "Error happeded while executing PromoteDomainController ...
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (Error happeded ...hell.Security'.:String) [], RuntimeException
    + FullyQualifiedErrorId : Error happeded while executing PromoteDomainController.ps1:The 'ConvertTo-SecureString'
   command was found in the module 'Microsoft.PowerShell.Security', but the module could not be loaded. For more info
  rmation, run 'Import-Module Microsoft.PowerShell.Security'.
```

![](https://raw.githubusercontent.com/antnn/is-it-pwsh-bug-qm/refs/heads/main/pwsh2.png)
