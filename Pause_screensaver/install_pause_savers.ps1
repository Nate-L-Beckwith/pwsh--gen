# Installer script to set up shortcuts and handle execution policy for screensaver script

# Define paths for the main script and the shortcuts
$scriptPath = "Pause_screensavers\pause_savers.ps1" # Main script is in the same folder
$desktopShortcutPath = [System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), 'Pause Screensaver.lnk')
$startMenuFolder = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs')
$startMenuShortcutPath = [System.IO.Path]::Combine($startMenuFolder, 'Pause Screensaver.lnk')
$startMenuStatusShortcutPath = [System.IO.Path]::Combine($startMenuFolder, 'Check Pause Screensaver Status.lnk')

$startupFolder = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs\Startup')
$startupScriptPath = [System.IO.Path]::Combine($startupFolder, [System.IO.Path]::GetFileName($scriptPath))

# Function to set execution policy for the current user if needed
function Set-ExecutionPolicyIfNeeded {
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if ($currentPolicy -ne 'RemoteSigned') {
        Write-Host "Setting execution policy to RemoteSigned for the current user..."
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    } else {
        Write-Host "Execution policy is already set to RemoteSigned for the current user."
    }
}

# Function to create a shortcut
function Create-Shortcut {
    param (
        [string]$targetPath,
        [string]$shortcutPath,
        [string]$description,
        [string]$arguments = ""
    )
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $targetPath
    $shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName($targetPath)
    $shortcut.Arguments = $arguments
    $shortcut.Description = $description
    $shortcut.Save()
    Write-Host "Shortcut created at $shortcutPath"
}

# Function to create Start Menu and desktop shortcuts
function Create-Shortcuts {
    if (-not (Test-Path $desktopShortcutPath)) {
        Create-Shortcut -targetPath $scriptPath -shortcutPath $desktopShortcutPath -description "Pause Screensaver Script"
    } else {
        Write-Host "Desktop shortcut already exists."
    }

    if (-not (Test-Path $startMenuShortcutPath)) {
        Create-Shortcut -targetPath $scriptPath -shortcutPath $startMenuShortcutPath -description "Pause Screensaver Script"
    } else {
        Write-Host "Start Menu shortcut already exists."
    }

    if (-not (Test-Path $startMenuStatusShortcutPath)) {
        Create-Shortcut -targetPath $scriptPath -shortcutPath $startMenuStatusShortcutPath -description "Check Pause Screensaver Status" -arguments "-status"
    } else {
        Write-Host "Start Menu status shortcut already exists."
    }
}

# Function to add the script to startup
function Add-ScriptToStartup {
    if (-not (Test-Path $startupScriptPath)) {
        Copy-Item -Path $scriptPath -Destination $startupScriptPath
        Write-Host "Script added to startup."
    } else {
        Write-Host "Script is already in startup."
    }
}

# Function to remove the script from startup
function Remove-ScriptFromStartup {
    if (Test-Path $startupScriptPath) {
        Remove-Item -Path $startupScriptPath
        Write-Host "Script removed from startup."
    } else {
        Write-Host "Script is not in startup."
    }
}

# Function to check if the script should be added to startup
function Prompt-AddToStartup {
    $response = Read-Host "Do you want to add the script to startup? (yes/no)"
    if ($response -eq "yes") {
        Add-ScriptToStartup
    } else {
        Write-Host "Script will not be added to startup."
    }
}

# Main installation logic

# 1. Set execution policy for the current session or user if needed
Set-ExecutionPolicyIfNeeded

# 2. Create shortcuts
Create-Shortcuts

# 3. Prompt to add the script to startup
Prompt-AddToStartup

Write-Host "Installation complete."
