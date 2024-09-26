# Bug Summary: 
## Add-Type Failure in Elevated PowerShell Process
Running on Microsoft Windows NT 10.0.20348.0

## Description:
When running Add-Type command in an elevated PowerShell process started programmatically, it fails with an error related to file paths or assemblies not being found. The same code works fine when run directly in an admin PowerShell window launched from the GUI.

## Key Points:
1. The issue occurs when using Start-Process to launch an elevated PowerShell session.
2. The Add-Type command works in a regular PowerShell session.
3. The error suggests problems with file paths or assembly references.
4. Importantly, the code compiles and adds the type successfully in the root (first) process (the non-elevated PowerShell session that initiates the elevated process).
