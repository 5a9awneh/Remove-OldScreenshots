# Remove-OldScreenshots

<!-- BADGES:START -->
[![License](https://img.shields.io/github/license/5a9awneh/Remove-OldScreenshots)](LICENSE) [![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?logo=powershell&logoColor=white)](https://learn.microsoft.com/en-us/powershell/) [![Windows](https://img.shields.io/badge/Windows-0078D6?logo=windows&logoColor=white)](https://www.microsoft.com/windows) [![Last Commit](https://img.shields.io/github/last-commit/5a9awneh/Remove-OldScreenshots)](https://github.com/5a9awneh/Remove-OldScreenshots/commits/main) [![Human in the Loop](https://img.shields.io/badge/human--in--the--loop-%E2%9C%93-brightgreen?style=flat)](https://github.com/5a9awneh/Remove-OldScreenshots)
<!-- BADGES:END -->

Automatically deletes screenshots and screen recordings older than a configurable number of days from the default Windows user folders.

---

**`ScreenshotCleanup.log` after a scheduled run:**

```
2026-05-06 12:00:03 - Starting cleanup process. Retention period: 7 days
2026-05-06 12:00:03 - Deleted: C:\Users\[USER]\Pictures\Screenshots\Screenshot 2026-04-27 143201.png
2026-05-06 12:00:03 - Deleted: C:\Users\[USER]\Pictures\Screenshots\Screenshot 2026-04-28 090512.png
2026-05-06 12:00:03 - Deleted: C:\Users\[USER]\Videos\Screen Recordings\Recording 2026-04-25 162340.mp4
2026-05-06 12:00:04 - Cleanup completed. Deleted: 2 screenshots and 1 screen recordings older than 7 days.
```
*(representative)*

---

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
$settings = New-ScheduledTaskSettingsSet -Hidden -StartWhenAvailable
Register-ScheduledTask -TaskName "Remove-OldScreenshots" -Action $action -Trigger $trigger -Settings $settings
```

**Hourly:**

```powershell
$scriptPath = "C:\path\to\Remove-OldScreenshots.ps1"
$action   = New-ScheduledTaskAction -Execute "powershell.exe" `
                -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`" -DaysToKeep 7"
$trigger  = New-ScheduledTaskTrigger -Once -At (Get-Date) `
                -RepetitionInterval (New-TimeSpan -Hours 1)
$settings = New-ScheduledTaskSettingsSet -Hidden -StartWhenAvailable
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
