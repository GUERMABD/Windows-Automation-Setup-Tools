@echo off
:: On dit a la console d'utiliser l'encodage UTF-8 pour les accents
chcp 65001 >nul

:: ====================================================
:: CONFIGURATION
:: Remplacez Wi-Fi par le nom de votre carte si besoin
set "ADAPTER_NAME=Wi-Fi"
:: ====================================================

:: Verification des droits administrateur
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :run
) else (
    powershell -Command "Start-Process '%~0' -Verb RunAs"
    exit
)

:run
:: Logique PowerShell avec boite de dialogue compatible UTF-8
powershell -Command ^
    "Add-Type -AssemblyName System.Windows.Forms;" ^
    "$nic = '%ADAPTER_NAME%';" ^
    "$dns = Get-DnsClientServerAddress -InterfaceAlias $nic -AddressFamily IPv4;" ^
    "if ($dns.ServerAddresses -contains '1.1.1.1') {" ^
    "    Set-DnsClientServerAddress -InterfaceAlias $nic -ResetServerAddresses;" ^
    "    [System.Windows.Forms.MessageBox]::Show('DNS désactivé. Retour en mode AUTOMATIQUE.', 'Statut DNS', 0, 64);" ^
    "} else {" ^
    "    Set-DnsClientServerAddress -InterfaceAlias $nic -ServerAddresses ('1.1.1.1', '1.0.0.1', '2606:4700:4700::1111', '2606:4700:4700::1001');" ^
    "    [System.Windows.Forms.MessageBox]::Show('DNS Cloudflare ACTIVÉ avec succès !', 'Statut DNS', 0, 64);" ^
    "}"