# Remove-OldScreenshots

<!-- BADGES:START -->
[![License](https://img.shields.io/github/license/5a9awneh/Remove-OldScreenshots)](LICENSE) [![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?logo=powershell&logoColor=white)](https://learn.microsoft.com/en-us/powershell/) [![Windows](https://img.shields.io/badge/Windows-0078D6?logo=windows&logoColor=white)](https://www.microsoft.com/windows) [![Last Commit](https://img.shields.io/github/last-commit/5a9awneh/Remove-OldScreenshots)](https://github.com/5a9awneh/Remove-OldScreenshots/commits/main) [<img src="https://madebyhuman.iamjarl.com/badges/loop-white.svg" alt="Human in the Loop" height="20">](https://madebyhuman.iamjarl.com)
<!-- BADGES:END -->

Automatically deletes screenshots and screen recordings older than a configurable number of days from the default Windows user folders.

## ⚙️ Requirements

- Windows
- PowerShell 5.1 or later
- Default `Pictures\Screenshots` and `Videos\Screen Recordings` folders must exist

## 🔧 Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `-DaysToKeep` | `int` | `7` | Files older than this many days are deleted |

## 🚀 Usage

**Manual:**

```powershell
.\Remove-OldScreenshots.ps1
.\Remove-OldScreenshots.ps1 -DaysToKeep 14
```

### ⏰ Scheduled Task Setup

Task creation is not handled by the script. Use one of the snippets below to register it as a silent scheduled task.

**Daily at noon with up to 30-minute random delay:**

```powershell
$scriptPath = "C:\path\to\Remove-OldScreenshots.ps1"
$action   = New-ScheduledTaskAction -Execute "powershell.exe" `
                -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`" -DaysToKeep 7"
$trigger  = New-ScheduledTaskTrigger -Daily -At "12:00PM"
$trigger.RandomDelay = "PT30M"
$settings = New-ScheduledTaskSettingsSet -Hidden
Register-ScheduledTask -TaskName "Remove-OldScreenshots" -Action $action -Trigger $trigger -Settings $settings
```

**Hourly:**

```powershell
$scriptPath = "C:\path\to\Remove-OldScreenshots.ps1"
$action   = New-ScheduledTaskAction -Execute "powershell.exe" `
                -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`" -DaysToKeep 7"
$trigger  = New-ScheduledTaskTrigger -Once -At (Get-Date) `
                -RepetitionInterval (New-TimeSpan -Hours 1)
$settings = New-ScheduledTaskSettingsSet -Hidden
Register-ScheduledTask -TaskName "Remove-OldScreenshots" -Action $action -Trigger $trigger -Settings $settings
```

## 🔍 How It Works

1. Resolves folder paths via Windows environment APIs — no hard-coded user paths
2. Recursively scans both folders for files with a last-write time older than `-DaysToKeep` days
3. Deletes matching files and logs each deletion (and any errors) to `ScreenshotCleanup.log` in the script directory

## 📝 Notes

- `ScreenshotCleanup.log` is written alongside the script — rotate or delete it periodically
- Errors (e.g. locked files) are caught and logged; the script never surfaces a dialog or breaks the task
- Only files are deleted — empty subdirectories are left in place
