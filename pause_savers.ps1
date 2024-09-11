# Full Script to disable screensaver, prompt after 5 hours, and re-enable or extend
$registryPath = "HKCU:\Control Panel\Desktop"
$screenSaveActiveValue = Get-ItemProperty -Path $registryPath -Name "ScreenSaveActive"
$extendPromptTime = 18000  # 5 hours in seconds

function Disable-Screensaver {
    # Disable Screensaver
    Set-ItemProperty -Path $registryPath -Name "ScreenSaveActive" -Value 0
    Write-Host "Screensaver disabled."
}

function Enable-Screensaver {
    # Re-enable Screensaver
    Set-ItemProperty -Path $registryPath -Name "ScreenSaveActive" -Value 1
    Write-Host "Screensaver re-enabled."
}

function Prompt-Extend {
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

# Main Script

# Disable Screensaver on login
Disable-Screensaver

# Start the 5-hour wait
Start-Sleep -Seconds $extendPromptTime

# After 5 hours, ask the user if they want to extend the disable period
Prompt-Extend
