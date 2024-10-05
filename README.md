# Bug Summary: 
[See also](https://github.com/antnn/is-it-pwsh-bug-qm?tab=readme-ov-file#if-i-run-pwsh-sriptps1-powershell-74)
## Add-Type Failure in Elevated PowerShell Process: 
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
## It seems it fixed in pwsh core `PowerShell 7.4.5`

## Description:
When running `Add-Type` command in an elevated `PowerShell` process started programmatically, it fails with an error related to file paths or assemblies not being found. The same code works fine when run directly in an admin PowerShell window launched from the GUI.

## Key Points:
1. The issue occurs when using `Start-Process` to launch an elevated PowerShell session.
2. The Add-Type command works in a regular `PowerShell` session.
3. The error suggests problems with file paths or assembly references.
4. Importantly, the code compiles and adds the type successfully in the root (first) process (the non-elevated PowerShell session that initiates the elevated process).

![pwsh_screeen](https://github.com/antnn/is-it-pwsh-bug-qm/blob/main/pwsh_bug.png?raw=true)

# If I run pwsh (powershell 7.4)
with [.\start.ps1](https://github.com/antnn/win-setup-action-ansible/blob/c6cbfe42ba5d0d78c285a8abd776ccbd4b39c5c8/action_plugins/templates/start.ps1#L20)
When it calls `ConvertTo-SecureString` inside child powershell [`Promote to DC`](https://github.com/microsoft/WindowsProtocolTestSuites/blob/797a4fa636a8eb0676f345950e2dddf2c394394e/CommonScripts/PromoteDomainController.ps1#L45).<br>
*`start.ps1` is similar to the code in this repo `start-process -credential ...`* <br>
#### I get this
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
