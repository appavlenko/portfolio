# Prompt for the PC name and user credentials
$PC = Read-Host "PC Name"
$Credential = Get-Credential

# Establish a remote session with the specified PC
$session = New-PSSession -ComputerName $PC -Credential $Credential

# Check if the session was successfully created
if (-not $session) {
    Write-Output "Failed to create a session. Check credentials or remote computer availability."
    return
}

# Verify that the session is in the 'Opened' state
if ($session.State -ne 'Opened') {
    Write-Output "Session is closed or in an incorrect state."
    Remove-PSSession $session
    return
}

# Define the required free space for installation and check the system drive
$freeSpaceRequired = 20GB  # 20 Gigabytes
$diskCheck = Invoke-Command -Session $session -ScriptBlock {
    $systemDrive = $env:SystemRoot.Substring(0, 2)
    $drive = Get-PSDrive -Name $systemDrive.Replace(":", "")
    [PSCustomObject]@{
        SystemDrive = $systemDrive
        FreeSpace = $drive.Free
        IsEnough = $drive.Free -ge $using:freeSpaceRequired
    }
}

# Check if there is enough free space on the system drive
if (-not $diskCheck.IsEnough) {
    Write-Output "Not enough free space on the system drive: $($diskCheck.FreeSpace / 1GB) GB."
    Remove-PSSession $session
    return
} else {
    Write-Output "Enough free space available for installation: $($diskCheck.FreeSpace / 1GB) GB."
}

# Copy the installation files to the remote computer
try {
    $destinationPath = $diskCheck.SystemDrive + "\WindowsSetup"
    Copy-Item -Path "*\Windows22H2April" -Destination $destinationPath -Recurse -Force -ToSession $session
} catch {
    Write-Output "Error occurred during file copy: $_"
    Remove-PSSession $session
    return
}

# Execute the installation process on the remote computer
Invoke-Command -Session $session -ScriptBlock {
    Start-Process -NoNewWindow -Wait -FilePath "${using:destinationPath}\setup.exe" -ArgumentList "/quiet /eula accept /auto upgrade /dynamicupdate enable /copylogs C:\WindowsSetup\logs"
Remove-PSSession $session
