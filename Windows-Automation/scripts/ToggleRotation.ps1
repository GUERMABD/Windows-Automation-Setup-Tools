# 1. Code C# pour l'interaction avec l'affichage (user32.dll)
$DisplayCode = @"
using System;
using System.Runtime.InteropServices;

public class DisplayAdmin {
    [StructLayout(LayoutKind.Sequential)]
    public struct DEVMODE {
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmDeviceName;
        public short dmSpecVersion; public short dmDriverVersion; public short dmSize; public short dmDriverExtra;
        public int dmFields; public int dmPositionX; public int dmPositionY; public int dmDisplayOrientation;
        public int dmDisplayFixedOutput; public short dmColor; public short dmDuplex; public short dmYResolution;
        public short dmTTOption; public short dmCollate; [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmFormName;
        public short dmLogPixels; public int dmBitsPerPel; public int dmPelsWidth; public int dmPelsHeight;
        public int dmDisplayFlags; public int dmNup; public int dmDisplayFrequency;
    }

    [DllImport("user32.dll")] public static extern int EnumDisplaySettings(string lpszDeviceName, int iModeNum, ref DEVMODE lpDevMode);
    [DllImport("user32.dll")] public static extern int ChangeDisplaySettings(ref DEVMODE lpDevMode, int dwFlags);

    public static void SetLandscape() {
        DEVMODE devMode = new DEVMODE();
        devMode.dmSize = (short)Marshal.SizeOf(typeof(DEVMODE));
        if (EnumDisplaySettings(null, -1, ref devMode) != 0) {
            if (devMode.dmDisplayOrientation != 0) {
                int temp = devMode.dmPelsWidth;
                devMode.dmPelsWidth = devMode.dmPelsHeight;
                devMode.dmPelsHeight = temp;
                devMode.dmDisplayOrientation = 0;
                ChangeDisplaySettings(ref devMode, 0);
            }
        }
    }
}
"@

if (-not ([System.Management.Automation.PSTypeName]'DisplayAdmin').Type) {
    Add-Type -TypeDefinition $DisplayCode
}

# Fonction pour afficher la notification Windows
function Show-Notification ($Title, $Text) {
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $Notification = New-Object System.Windows.Forms.NotifyIcon
    $Notification.Icon = [System.Drawing.SystemIcons]::Information
    $Notification.BalloonTipTitle = $Title
    $Notification.BalloonTipText = $Text
    $Notification.Visible = $True
    $Notification.ShowBalloonTip(3000)
}

# 2. Gestion du registre et etats
$RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AutoRotation"
if (-not (Test-Path $RegistryPath)) { New-Item -Path $RegistryPath -Force | Out-Null }

$CurrentState = (Get-ItemProperty -Path $RegistryPath -Name "Enable" -ErrorAction SilentlyContinue).Enable

if ($CurrentState -eq 1) {
    # --- MODE 1 : Verrouille en Paysage ---
    [DisplayAdmin]::SetLandscape()
    Set-ItemProperty -Path $RegistryPath -Name "LastOrientation" -Value 0
    Set-ItemProperty -Path $RegistryPath -Name "Enable" -Value 0
    
    Show-Notification -Title "Rotation Ecran" -Text "Mode Paysage Fixe - Verrouille"
} else {
    # --- MODE 2 : Rotation Auto Activee ---
    Set-ItemProperty -Path $RegistryPath -Name "Enable" -Value 1
    
    Show-Notification -Title "Rotation Ecran" -Text "Mode Libre - Rotation Auto Activee"
}