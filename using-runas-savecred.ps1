
function Start-WinServer22-Elevated-With-RunAs($adminUserName) {
    $csharpCode = @"
using System;
using System.Runtime.InteropServices;
using System.Text;

public class RunAsCredentialManager
{
    static void Main()
    {
        RunAsCredentialManager.WriteCredential("Mainserver\\Administrator", "MainServer\\Ieuser", "Passw0rd!");
    }
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct CREDENTIAL
    {
        public uint Flags;
        public uint Type;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string TargetName;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string Comment;
        public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
        public uint CredentialBlobSize;
        public IntPtr CredentialBlob;
        public uint Persist;
        public uint AttributeCount;
        public IntPtr Attributes;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string TargetAlias;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string UserName;
    }

    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    private static extern bool CredWrite([In] ref CREDENTIAL credential, [In] uint flags);

    [DllImport("kernel32.dll")]
    private static extern uint GetLastError();

    private const uint CRED_TYPE_DOMAIN_PASSWORD = 2;
    private const uint CRED_PERSIST_LOCAL_MACHINE = 3;

    public static bool WriteCredential(string targetName, string userName, string password)
    {
        byte[] passwordBytes = Encoding.Unicode.GetBytes(password);
        uint blobSize = (uint)passwordBytes.Length;

        CREDENTIAL cred = new CREDENTIAL
        {
            Flags = 8196,
            Type = CRED_TYPE_DOMAIN_PASSWORD,
            TargetName = targetName,
            CredentialBlobSize = blobSize,
            CredentialBlob = Marshal.AllocHGlobal((int)blobSize),
            Persist = CRED_PERSIST_LOCAL_MACHINE,
            UserName = userName
        };

        Marshal.Copy(passwordBytes, 0, cred.CredentialBlob, (int)blobSize);

        try
        {
            if (!CredWrite(ref cred, 0))
            {
                uint error = GetLastError();
                Console.Error.WriteLine("CredWrite failed with error code: {error}");
                return false;
            }
            return true;
        }
        finally
        {
            Marshal.FreeHGlobal(cred.CredentialBlob);
        }
    }
}
"@

    # Add the C# type to the PowerShell session
    Add-Type -TypeDefinition $csharpCode -Language CSharp

    # To use with /runas /cred
    [RunAsCredentialManager]::WriteCredential("$env:COMPUTERNAME\$adminUserName", "$env:COMPUTERNAME\$adminUserName", "$adminPassword")

    runas /savecred /user:"$env:COMPUTERNAME\$adminUserName" "powershell.exe -NoExit -ExecutionPolicy Bypass $PSCommandPath"

}
