Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Advanced Auto Clicker"
$form.Size = New-Object System.Drawing.Size(450, 380)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

# Custom color palette
$colorPrimary = [System.Drawing.Color]::FromArgb(64, 64, 122)
$colorSecondary = [System.Drawing.Color]::FromArgb(100, 100, 180)
$colorBackground = [System.Drawing.Color]::FromArgb(240, 240, 250)

# Title Label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Auto Clicker"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = $colorPrimary
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$titleLabel.Size = New-Object System.Drawing.Size(400, 40)
$titleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($titleLabel)

# Interval Group Box
$intervalGroupBox = New-Object System.Windows.Forms.GroupBox
$intervalGroupBox.Text = " Click Interval Settings "
$intervalGroupBox.Location = New-Object System.Drawing.Point(20, 70)
$intervalGroupBox.Size = New-Object System.Drawing.Size(400, 120)
$intervalGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($intervalGroupBox)

# Minimum Interval Label and TextBox
$minLabel = New-Object System.Windows.Forms.Label
$minLabel.Text = "Minimum Interval (sec)"
$minLabel.Location = New-Object System.Drawing.Point(20, 30)
$minLabel.Size = New-Object System.Drawing.Size(150, 25)
$minLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$intervalGroupBox.Controls.Add($minLabel)

$minTextBox = New-Object System.Windows.Forms.TextBox
$minTextBox.Location = New-Object System.Drawing.Point(200, 30)
$minTextBox.Size = New-Object System.Drawing.Size(150, 25)
$minTextBox.Text = "0.5"
$minTextBox.BackColor = [System.Drawing.Color]::White
$minTextBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$intervalGroupBox.Controls.Add($minTextBox)

# Maximum Interval Label and TextBox
$maxLabel = New-Object System.Windows.Forms.Label
$maxLabel.Text = "Maximum Interval (sec)"
$maxLabel.Location = New-Object System.Drawing.Point(20, 70)
$maxLabel.Size = New-Object System.Drawing.Size(150, 25)
$maxLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$intervalGroupBox.Controls.Add($maxLabel)

$maxTextBox = New-Object System.Windows.Forms.TextBox
$maxTextBox.Location = New-Object System.Drawing.Point(200, 70)
$maxTextBox.Size = New-Object System.Drawing.Size(150, 25)
$maxTextBox.Text = "3.0"
$maxTextBox.BackColor = [System.Drawing.Color]::White
$maxTextBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$intervalGroupBox.Controls.Add($maxTextBox)

# Status Label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, 280)
$statusLabel.Size = New-Object System.Drawing.Size(400, 30)
$statusLabel.Text = "Status: Ready to Click"
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
$statusLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($statusLabel)

# Button Panel
$buttonPanel = New-Object System.Windows.Forms.Panel
$buttonPanel.Location = New-Object System.Drawing.Point(20, 210)
$buttonPanel.Size = New-Object System.Drawing.Size(400, 50)
$buttonPanel.BackColor = [System.Drawing.Color]::Transparent
$form.Controls.Add($buttonPanel)

# Start Button
$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = " Start Clicking"
$startButton.Location = New-Object System.Drawing.Point(20, 0)
$startButton.Size = New-Object System.Drawing.Size(170, 40)
$startButton.BackColor = $colorPrimary
$startButton.ForeColor = [System.Drawing.Color]::White
$startButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$startButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$buttonPanel.Controls.Add($startButton)

# Stop Button
$stopButton = New-Object System.Windows.Forms.Button
$stopButton.Text = " Stop Clicking"
$stopButton.Location = New-Object System.Drawing.Point(210, 0)
$stopButton.Size = New-Object System.Drawing.Size(170, 40)
$stopButton.BackColor = [System.Drawing.Color]::Crimson
$stopButton.ForeColor = [System.Drawing.Color]::White
$stopButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$stopButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$stopButton.Enabled = $false
$buttonPanel.Controls.Add($stopButton)

# Global variables for clicking
$script:isClicking = $false
$script:randomClicker = $null

# Start Button Click Event
$startButton.Add_Click({
    try {
        $minInterval = [double]$minTextBox.Text
        $maxInterval = [double]$maxTextBox.Text

        if ($minInterval -le 0 -or $maxInterval -le 0) {
            [System.Windows.Forms.MessageBox]::Show("Intervals must be positive numbers.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        if ($minInterval -gt $maxInterval) {
            [System.Windows.Forms.MessageBox]::Show("Minimum interval cannot be greater than maximum interval.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        # Stop any existing job
        if ($script:randomClicker) {
            Stop-Job -Job $script:randomClicker -ErrorAction SilentlyContinue
            Remove-Job -Job $script:randomClicker -ErrorAction SilentlyContinue
        }

        # Start a new background job for clicking
        $script:randomClicker = Start-Job -ScriptBlock {
            param($min, $max)
            Add-Type -AssemblyName System.Windows.Forms
            while ($true) {
                $pos = [System.Windows.Forms.Cursor]::Position
                $signature = @'
[DllImport("user32.dll")]
public static extern void mouse_event(int dwFlags, int dx, int dy, int cButtons, int dwExtraInfo);
'@
                $sendMouseClick = Add-Type -MemberDefinition $signature -Name "Win32MouseClick" -Namespace Win32Functions -PassThru
                $sendMouseClick::mouse_event(2, 0, 0, 0, 0)  # Left down
                Start-Sleep -Milliseconds 10
                $sendMouseClick::mouse_event(4, 0, 0, 0, 0)  # Left up
                $interval = Get-Random -Minimum $min -Maximum $max
                Start-Sleep -Seconds $interval
            }
        } -ArgumentList $minInterval, $maxInterval

        $statusLabel.Text = " Clicking started. Move mouse to desired position."
        $startButton.Enabled = $false
        $stopButton.Enabled = $true
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error starting auto-clicker: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

# Stop Button Click Event
$stopButton.Add_Click({
    if ($script:randomClicker) {
        Stop-Job -Job $script:randomClicker
        Remove-Job -Job $script:randomClicker
        $script:randomClicker = $null
        $statusLabel.Text = " Clicking stopped."
        $startButton.Enabled = $true
        $stopButton.Enabled = $false
    }
})

# Help Button
$helpButton = New-Object System.Windows.Forms.Button
$helpButton.Text = " Help"
$helpButton.Location = New-Object System.Drawing.Point(170, 320)
$helpButton.Size = New-Object System.Drawing.Size(100, 30)
$helpButton.BackColor = $colorSecondary
$helpButton.ForeColor = [System.Drawing.Color]::White
$helpButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$helpButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$helpButton.Add_Click({
    $helpMessage = @"
Auto Clicker Instructions:

1. Set minimum and maximum click intervals
2. Click 'Start Clicking'
3. Move mouse to desired clicking position
4. Click 'Stop Clicking' to end

Tips:
- Intervals are in seconds
- Minimum interval must be less than maximum
- Be careful when using auto-clicker
"@
    [System.Windows.Forms.MessageBox]::Show($helpMessage, "Help", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})
$form.Controls.Add($helpButton)

# Cleanup on Form Close
$form.Add_FormClosed({
    if ($script:randomClicker) {
        Stop-Job -Job $script:randomClicker -ErrorAction SilentlyContinue
        Remove-Job -Job $script:randomClicker -ErrorAction SilentlyContinue
    }
})

# Show the form
$form.ShowDialog() | Out-Null
