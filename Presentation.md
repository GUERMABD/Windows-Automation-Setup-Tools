# Windows Automation & Setup Tools 🚀

Ce dépôt rassemble un ensemble de scripts et de configurations pour automatiser des tâches quotidiennes sur Windows 11 (gestion du DNS, mode travail, mise à jour des logiciels, activation du tactile).

## 🛠️ Contenu du projet

* **Mode Works** (`Works.ps1` + `LanceurWorksInvisible.vbs`) : Lance simultanément Discord et Notion en arrière-plan de manière invisible.
* **Toggle Tactile** (`Tactile.ps1`) : Active ou désactive rapidement l'écran tactile.
* **Toggle DNS** (`ToggleDNS.bat`) : Alterne entre différentes configurations DNS.
* **MAJ Winget** : Force la mise à jour de toutes les applications via `winget upgrade --all` en contournant l'UAC via le Planificateur de tâches.

---

## 🚀 Installation & Configuration

### 1. Cloner le projet
Place ce dossier dans un répertoire permanent (ex: `C:\Scripts\`).

### 2. Importer les Tâches Planifiées
Pour éviter les demandes de droits administrateur (UAC) à chaque exécution, importez les fichiers `.xml` dans le **Planificateur de tâches** de Windows :
1. Ouvrez le `Planificateur de tâches`.
2. Cliquez sur **Importer une tâche...** dans le volet de droite.
3. Sélectionnez les fichiers présents dans le dossier `/tasks`.
4. *Note : Pensez à vérifier et modifier les chemins d'accès des scripts dans l'onglet "Actions" de chaque tâche pour qu'ils correspondent à votre dossier local.*

### 3. Créer les raccourcis sur le Bureau
Pour exécuter ces tâches instantanément depuis votre bureau, créez un nouveau raccourci avec la cible suivante : schtasks /run /tn "Nom_De_La_Tache_Dans_Le_Planificateur"

## 4. Attention aux données sensibles ⚠️

Avant de faire ton premier `git commit`, ouvre tes scripts (`ToggleDNS.bat`, `Works.ps1`, etc.) et vérifie :
* Qu'il n'y ait pas de **mots de passe** écrits en dur.
* Qu'il n'y ait pas de chemins d'accès contenant des identifiants trop privés si tu tiens à ton anonymat (même si ici, `guerm` ou `Abderhamane` ne posent aucun problème de sécurité en soi, c'est une bonne habitude à prendre).

Tu as déjà un compte GitHub et Git installé sur ta machine pour mettre ça en place, ou tu veux qu'on reprenne les commandes de base pour initialiser le dépôt ?
