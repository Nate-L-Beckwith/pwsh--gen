Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-Notification($text, $title) {
    $balloon = New-Object System.Windows.Forms.NotifyIcon
    $balloon.Icon = [System.Drawing.SystemIcons]::Information
    $balloon.BalloonTipText = $text
    $balloon.BalloonTipTitle = $title
    $balloon.Visible = $true
    $balloon.ShowBalloonTip(5000)
}

# GUI for time selection and status check
function Show-GUI {
    $form = New-Object Windows.Forms.Form
    $form.Text = "Pause Screensaver"
    $form.Size = New-Object Drawing.Size(300, 200)
    $form.StartPosition = "CenterScreen"

    # Label for time selection
    $label = New-Object Windows.Forms.Label
    $label.Text = "Select Time to Pause (hours):"
    $label.Location = New-Object Drawing.Point(50, 20)
    $form.Controls.Add($label)

    # ComboBox for time selection
    $comboBox = New-Object Windows.Forms.ComboBox
    $comboBox.Location = New-Object Drawing.Point(50, 50)
    $comboBox.Width = 100
    $comboBox.Items.AddRange(1..12)  # Add options for 1 to 12 hours
    $form.Controls.Add($comboBox)

    # Button to pause screensaver
    $pauseButton = New-Object Windows.Forms.Button
    $pauseButton.Text = "Pause"
    $pauseButton.Location = New-Object Drawing.Point(50, 100)
    $pauseButton.Add_Click({
        if ($comboBox.SelectedItem) {
            $global:extensionTime = $comboBox.SelectedItem * 3600  # Convert hours to seconds
            Start-Job -ScriptBlock {
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "ScreenSaveActive" -Value 0
                Start-Sleep -Seconds $global:extensionTime
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "ScreenSaveActive" -Value 1
            }
            Show-Notification "Screensaver disabled for $($comboBox.SelectedItem) hours." "Pause Screensaver"
            $form.Close()
        } else {
            [Windows.Forms.MessageBox]::Show("Please select a valid time.")
        }
    })
    $form.Controls.Add($pauseButton)

    # Button to check status
    $statusButton = New-Object Windows.Forms.Button
    $statusButton.Text = "Check Status"
    $statusButton.Location = New-Object Drawing.Point(150, 100)
    $statusButton.Add_Click({
        $job = Get-Job | Where-Object { $_.State -eq 'Running' }
        if ($job) {
            $remainingTime = $global:extensionTime - (Get-Date).Subtract($job.PSBeginTime).TotalSeconds
            Show-Notification "Remaining time: $([math]::Round($remainingTime/3600, 2)) hours" "Pause Screensaver Status"
        } else {
            Show-Notification "Screensaver is not paused." "Pause Screensaver Status"
        }
    })
    $form.Controls.Add($statusButton)

    $form.ShowDialog() | Out-Null
}

# Run the GUI
Show-GUI
