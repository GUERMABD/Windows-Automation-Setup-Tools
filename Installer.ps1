$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$WshShell = New-Object -ComObject WScript.Shell

# Fonction pour créer un raccourci qui lance une Tâche Planifiée (Contourne l'UAC)
function Create-TaskShortcut ($ShortcutName, $TaskName, $IconNumber) {
    $Shortcut = $WshShell.CreateShortcut("$DesktopPath\$ShortcutName.lnk")
    $Shortcut.TargetPath = "schtasks.exe"
    $Shortcut.Arguments = "/run /tn `"$TaskName`""
    $Shortcut.IconLocation = "shell32.dll,$IconNumber"
    $Shortcut.Save()
}

# Fonction pour importer et adapter le fichier XML au PC de l'utilisateur
function Import-Task ($XmlName, $TaskName) {
    $XmlPath = Join-Path $ScriptDir "tasks\$XmlName"
    if (Test-Path $XmlPath) {
        [xml]$xml = Get-Content $XmlPath
        
        # 1. Adapte le chemin du script dans le XML pour correspondre au dossier actuel
        $xml.Task.Actions.Exec.Command = $xml.Task.Actions.Exec.Command -replace "C:\\Users\\.*?\\Planificateur de taches", "$ScriptDir\scripts"
        $xml.Task.Actions.Exec.Command = $xml.Task.Actions.Exec.Command -replace "C:\\Users\\.*?\\Desktop\\Windows-Automation", $ScriptDir
        
        # 2. Nettoie l'identifiant de l'auteur pour éviter l'erreur de mappage
        if ($xml.Task.Principals.Principal.UserId) {
            $xml.Task.Principals.Principal.UserId = $env:USERDOMAIN + "\" + $env:USERNAME
        }
        
        $xml.Save($XmlPath)

        # Importation de la tâche
        schtasks /create /xml $XmlPath /tn "$TaskName" /F | Out-Null
        return $true
    }
    return $false
}

# Vérification des droits Administrateur
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Ce script necessite des droits Administrateur." -ForegroundColor Yellow
    Write-Host "Relance en cours avec les privileges eleves..." -ForegroundColor Cyan
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Clear-Host
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   Windows Automation Installer          " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Choisissez le programme a installer :"
Write-Host "1) Mode Works (Discord + Notion invisible)"
Write-Host "2) Toggle Ecran Tactile (ON/OFF)"
Write-Host "3) Toggle DNS (Changement rapide)"
Write-Host "4) MAJ Automatique des Logiciels (Winget)"
Write-Host "5) Toggle Rotation Ecran"
Write-Host "6) [ TOUT INSTALLER ]"
Write-Host "========================================="
$Choix = Read-Host "Entrez votre choix (1-6)"

switch ($Choix) {
    "1" {
        if (Import-Task "ToggleTactile.xml" "Works") {
            Create-TaskShortcut "Mode Works" "Works" "247"
            Write-Host "[OK] Mode Works installe sur le Bureau !" -ForegroundColor Green
        }
    }
    "2" {
        if (Import-Task "ToggleTactile.xml" "ToggleTactile") {
            Create-TaskShortcut "Tactile" "ToggleTactile" "141"
            Write-Host "[OK] Controle Tactile installe sur le Bureau !" -ForegroundColor Green
        }
    }
    "3" {
        if (Import-Task "ToggleDNS.xml" "ToggleDNS") {
            Create-TaskShortcut "ToggleDNS" "ToggleDNS" "135"
            Write-Host "[OK] Toggle DNS installe sur le Bureau !" -ForegroundColor Green
        }
    }
    "4" {
        if (Import-Task "MajWingetSansVerif.xml" "MajWinget") {
            Create-TaskShortcut "MAJ_Winget" "MajWinget" "46"
            Write-Host "[OK] MAJ Winget installe sur le Bureau !" -ForegroundColor Green
        }
    }
    "5" {
        $Shortcut = $WshShell.CreateShortcut("$DesktopPath\Rotation.lnk")
        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptDir\scripts\ToggleRotation.ps1`""
        $Shortcut.IconLocation = "shell32.dll,238"
        $Shortcut.Save()
        Write-Host "[OK] Raccourci Rotation installe sur le Bureau !" -ForegroundColor Green
    }
    "6" {
        [void](Import-Task "ToggleTactile.xml" "Works"); Create-TaskShortcut "Mode Works" "Works" "247"
        [void](Import-Task "ToggleTactile.xml" "ToggleTactile"); Create-TaskShortcut "Tactile" "ToggleTactile" "141"
        [void](Import-Task "ToggleDNS.xml" "ToggleDNS"); Create-TaskShortcut "ToggleDNS" "ToggleDNS" "135"
        [void](Import-Task "MajWingetSansVerif.xml" "MajWinget"); Create-TaskShortcut "MAJ_Winget" "MajWinget" "46"
        
        $Shortcut = $WshShell.CreateShortcut("$DesktopPath\Rotation.lnk")
        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptDir\scripts\ToggleRotation.ps1`""
        $Shortcut.IconLocation = "shell32.dll,238"
        $Shortcut.Save()
        
        Write-Host "Tous les programmes ont ete installes sur votre Bureau !" -ForegroundColor Green
    }
    default {
        Write-Host "Choix invalide." -ForegroundColor Red
    }
}

Write-Host ""
Read-Host "Appuyez sur Entree pour quitter..."