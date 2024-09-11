param (
    [switch]$onboot
)

# Function to check and set execution policy if needed
function Set-ExecutionPolicyIfNeeded {
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if ($currentPolicy -ne 'RemoteSigned') {
        Write-Host "Setting execution policy to RemoteSigned for CurrentUser..."
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    } else {
        Write-Host "Execution policy is already set to RemoteSigned for CurrentUser."
    }
}

# Function to add the script to the startup folder
function Add-ScriptToStartup {
    $scriptPath = $MyInvocation.MyCommand.Path
    $startupFolder = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs\Startup')
    $startupScriptPath = [System.IO.Path]::Combine($startupFolder, [System.IO.Path]::GetFileName($scriptPath))
    
    if (-not (Test-Path $startupFolder)) {
        New-Item -Path $startupFolder -ItemType Directory
    }

    if (-not (Test-Path $startupScriptPath)) {
        Copy-Item -Path $scriptPath -Destination $startupScriptPath
        Write-Host "Script added to startup folder."
    } else {
        Write-Host "Script is already in the startup folder."
    }
}

# Function to remove the script from the startup folder
function Remove-ScriptFromStartup {
    $scriptPath = $MyInvocation.MyCommand.Path
    $startupFolder = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs\Startup')
    $startupScriptPath = [System.IO.Path]::Combine($startupFolder, [System.IO.Path]::GetFileName($scriptPath))

    if (Test-Path $startupScriptPath) {
        Remove-Item -Path $startupScriptPath
        Write-Host "Script removed from startup folder."
    } else {
        Write-Host "Script is not in the startup folder."
    }
}

# Function to disable the screensaver
function Disable-Screensaver {
    $registryPath = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $registryPath -Name "ScreenSaveActive" -Value 0
    Write-Host "Screensaver disabled."
}

# Function to enable the screensaver
function Enable-Screensaver {
    $registryPath = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $registryPath -Name "ScreenSaveActive" -Value 1
    Write-Host "Screensaver re-enabled."
}

# Function to prompt the user to extend the screensaver disable time
function Prompt-Extend {
    $extendPromptTime = 18000  # 5 hours in seconds
    $response = Read-Host "Do you want to extend screensaver disable time for another 5 hours? (yes/no)"
    if ($response -eq "yes") {
        Write-Host "Extending screensaver disable time."
        Start-Sleep -Seconds $extendPromptTime
        Prompt-Extend  # Recursive call to keep asking every 5 hours
    } else {
        Write-Host "Re-enabling screensaver."
        Enable-Screensaver
    }
}

# Main script logic

# Check and set execution policy if needed
Set-ExecutionPolicyIfNeeded

# If the -onboot flag is provided, add the script to startup
if ($onboot) {
    Add-ScriptToStartup
} else {
    # Otherwise, remove it from startup if it's there
    Remove-ScriptFromStartup
}

# Disable the screensaver initially
Disable-Screensaver

# Wait for 5 hours before prompting to extend or re-enable
Start-Sleep -Seconds 18000  # 5 hours

# After 5 hours, prompt the user to extend the disable period
Prompt-Extend
