function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-LocalizedAdminAccountName {
    try {
        # SID for the built-in Administrator account
        $adminSID = "S-1-5-21-%-500"

        # Get the Administrator account using the SID
        $adminAccount = Get-WmiObject Win32_UserAccount -Filter "SID like '$adminSID'"

        if ($adminAccount) {
            return $adminAccount.Name
        }
        else {
            Write-Warning "Unable to find the Administrator account."
            return $null
        }
    }
    catch {
        Write-Error "An error occurred while trying to get the Administrator account name: $_"
        return $null
    }
}

$adminPassword = "Passw0rd!"
$adminUserName = Get-LocalizedAdminAccountName
function Start-ElevatedProcess() {
    $sourceCode = @"
    using System;
    
    public class TestClass
    {
        public static string GetMessage()
        {
            return "Hello from TestClass! Running on " + Environment.OSVersion.ToString();
        }
    }
"@
    $osVersion = [System.Environment]::OSVersion
    
    if ($osVersion.Version.Major -eq 6 -and $osVersion.Version.Minor -eq 1) {
        $language = "CSharpVersion3"
    } else {
        $language = "CSharp"
    }
    
    # Assuming $scriptAssembly is defined earlier in your script
    # If not, you might want to set it to a basic assembly like System.dll
    if (-not $scriptAssembly) {
        $scriptAssembly = "System.dll"
    }
    
    try {
        Add-Type -ReferencedAssemblies $scriptAssembly -TypeDefinition $sourceCode -Language $language -IgnoreWarnings
        
        # Test the newly created class
        $result = [TestClass]::GetMessage()
        Write-Host "Test result: $result" -ForegroundColor Green
    }
    catch {
        Write-Host "Error occurred while adding type:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }

    $adminUserName = Get-LocalizedAdminAccountName
    $PWord = ConvertTo-SecureString -String $adminPassword -AsPlainText -Force
    $adminCredential = New-Object -TypeName System.Management.Automation.PSCredential `
        -ArgumentList $adminUserName, $PWord
    if (-not (Test-Administrator)) {
           Start-Process powershell.exe -Credential $adminCredential `
        -ArgumentList "-NoExit -ExecutionPolicy Bypass ./is-it-pwsh-bug.ps1"
            return
    }
}
$info=@"
Bug Summary: Add-Type Failure in Elevated PowerShell Process
Running on Microsoft Windows NT 10.0.20348.0

Description:
When running Add-Type command in an elevated PowerShell process started programmatically, it fails with an error related to file paths or assemblies not being found. The same code works fine when run directly in an admin PowerShell window launched from the GUI.

Key Points:
1. The issue occurs when using Start-Process to launch an elevated PowerShell session.
2. The Add-Type command works in a regular PowerShell session.
3. The error suggests problems with file paths or assembly references.
4. Importantly, the code compiles and adds the type successfully in the root (first) process (the non-elevated PowerShell session that initiates the elevated process).

"@
Write-Output $info
Start-ElevatedProcess
exit
