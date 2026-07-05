Dim WShell
Set WShell = CreateObject("WScript.Shell")
' Le 0 à la fin signifie : cacher la fenêtre complètement
WShell.Run "powershell.exe -ExecutionPolicy Bypass -File ""C:\Users\guerm\OneDrive\Abderhamane Documents\Setup et Activation\Configuration\Planificateur de taches\Works.ps1""", 0
Set WShell = Nothing