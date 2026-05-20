# winCredEnum_v7
Windows Credintials Enumeration

An automated post-exploitation and privilege escalation reconnaissance script designed to seek out sensitive configuration files, historical command logs, and embedded cleartext/encrypted credentials on Windows operating systems. 

This tool is specifically optimized for security auditors, penetration testers, and CTF enthusiasts (such as TryHackMe/HackTheBox users) to accelerate the credential hunting phase of **Windows Privilege Escalation**.

---

##  Key Features

- **Automated Directory Lifecycle**: Dynamically checks for and provisions an isolated `./output/` directory for artifact extraction.
- **Sysprep & Unattended Enumeration**: Targets crucial setup/deployment files (`Unattend.xml`, `sysprep.inf`, `sysprep.xml`) across classic system paths where administrative passwords frequently reside.
- **Web Infrastructure Assessment**: Scans default and advanced installation paths for IIS `web.config` configurations to leak database string credentials and service account backings.
- **Registry Secrets Extraction**: Inspects the local machine's subkeys for `Winlogon\Autologon` passwords often left exposed for automated user entry.
- **Session History Salvaging**: Dynamically queries the `PSReadLine` engine abstractions to safely extract terminal history buffers even when custom scopes or environment layouts block regular environment pathing.
- **Safe Output Sanitization**: Sanitizes underlying source absolute paths into clean flat-file structures (e.g., `C_Windows_Panther_Unattend.xml.txt`) preventing string collision or write overwrite bugs.

---

## Target Locations Monitored

| Module | Exact Vector Target / Path | Target Risk Type |
| :--- | :--- | :--- |
| **Sysprep** | `C:\Unattend.xml` | Cleartext / Base64 System Setup Passwords |
| **Sysprep** | `C:\Windows\Panther\Unattend.xml` | Unattended Setup Configuration Cache |
| **Sysprep** | `C:\Windows\Panther\Unattend\Unattend.xml` | Core Panther Deployment Logins |
| **Sysprep** | `C:\Windows\system32\sysprep.inf` | Legacy Answer Files |
| **Sysprep** | `C:\Windows\system32\sysprep\sysprep.xml` | Sysprep XML Answer Templates |
| **IIS Web** | `C:\inetpub\wwwroot\web.config` | Database ConnectionStrings / Tokens |
| **IIS Web** | `C:\Windows\Microsoft.NET\...\web.config` | Global Framework Config / Machine Keys |
| **Registry** | `HKLM:\SOFTWARE\...\Winlogon` | DefaultPassword / Autologon Registrations |
| **Terminal**| `$env:APPDATA\...\ConsoleHost_history.txt` | PSReadLine Terminal Command History |
| **Cred Manager** | `cmdkey /list` | Saved Network/RDP Passwords (runas /savecred) |

---

## 🚀 Execution & Usage

### 1. Standard Bypass Run
If execution policies restrict script execution on the victim host, use the following execution context to cleanly bypass constraints:

```powershell
powershell -ExecutionPolicy Bypass -File .\winCredEnum_v3.ps1
```
### 2. Changing Session Policy (Proccess Level) : >

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```
Click Enter

```powershell
.\winCredEnum_v7.ps1
```


# ⚖️ Disclaimer

This utility is developed solely for authorized security testing, educational validation contexts within internal labs, and legitimate penetration testing engagements. Execution against production networks without prior official explicit written sign-off is strictly prohibited. The developer takes no responsibility for structural degradation or malicious utilization of this repository framework.

Copyright (c) 2026 Amr Mohamed Ragheb (King Of Noobs)
The Noobs state remains and expands ⚔ 