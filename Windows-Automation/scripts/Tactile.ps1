# Définition de l'encodage pour éviter les erreurs de caractères
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$device = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*tactile HID*" }
Add-Type -AssemblyName System.Windows.Forms

if ($device.Status -eq "OK") {
    Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false
    [System.Windows.Forms.MessageBox]::Show("Écran tactile : DÉSACTIVÉ", "Statut Tactile")
} else {
    Enable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false
    [System.Windows.Forms.MessageBox]::Show("Écran tactile : ACTIVÉ", "Statut Tactile")
}