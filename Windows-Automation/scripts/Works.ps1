# --- 1. DÉFINITION DES OUTILS SYSTÈME (Clavier + Gestion Fenêtres) ---
$code = @"
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, uint dwExtraInfo);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
"@
$Win32 = Add-Type -MemberDefinition $code -Name "Win32" -Namespace Win32 -PassThru

# Codes touches et commandes
$VK_LWIN  = 0x5B
$VK_LCTRL = 0xA2
$VK_D     = 0x44
$KEYUP    = 0x0002
$SW_MAXIMIZE = 3  # Le code magique pour forcer le plein écran

# Fonction pour créer le bureau
function Creer-Bureau {
    $Win32::keybd_event($VK_LWIN, 0, 0, 0)
    $Win32::keybd_event($VK_LCTRL, 0, 0, 0)
    $Win32::keybd_event($VK_D, 0, 0, 0)
    # Relâchement des touches
    $Win32::keybd_event($VK_D, 0, $KEYUP, 0)
    $Win32::keybd_event($VK_LCTRL, 0, $KEYUP, 0)
    $Win32::keybd_event($VK_LWIN, 0, $KEYUP, 0)
}

# --- 2. EXÉCUTION ---

# A. On crée le nouveau bureau
Creer-Bureau

# Pause pour laisser l'animation Windows se finir (très important)
Start-Sleep -Milliseconds 1500

# B. On lance Notion
Invoke-Item "C:\Users\guerm\Desktop\Notion.lnk"

# On attend que Notion s'ouvre réellement (augmentez si votre PC est lent)
Start-Sleep -Milliseconds 3000

# C. FORCER LE PLEIN ÉCRAN (Méthode intelligente)
# On cherche le processus Notion qui a une fenêtre visible
$processNotion = Get-Process "Notion" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 }

# Si on trouve Notion, on envoie l'ordre direct "Maximiser" (Code 3)
if ($processNotion) {
    $Win32::ShowWindow($processNotion.MainWindowHandle, $SW_MAXIMIZE)
}

# D. On lance Discord
Invoke-Item "C:\Users\guerm\Desktop\Discord.lnk"