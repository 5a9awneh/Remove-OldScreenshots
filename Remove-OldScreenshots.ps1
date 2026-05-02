param(
    [int]$DaysToKeep = 7
)

# Function to write log messages
function Write-Log {
    param([string]$Message)
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    Add-Content -Path "$PSScriptRoot\ScreenshotCleanup.log" -Value $logMessage
}

try {
    # Use the UserProfile environment variable to construct the path to Pictures and Videos
    $picturesPath = [Environment]::GetFolderPath('MyPictures')
    $videosPath = [Environment]::GetFolderPath('MyVideos')
    
    # Construct the full paths to the Screenshots and Screen Recordings folders
    $screenshotsPath = Join-Path -Path $picturesPath -ChildPath "Screenshots"
    $screenRecordingsPath = Join-Path -Path $videosPath -ChildPath "Screen Recordings"
    
    if (-not (Test-Path $screenshotsPath)) {
        throw "Screenshots folder not found: $screenshotsPath"
    }

    if (-not (Test-Path $screenRecordingsPath)) {
        throw "Screen Recordings folder not found: $screenRecordingsPath"
    }

    Write-Log "Starting cleanup process. Retention period: $DaysToKeep days"

    # Function to delete old files from a specified path
    function Delete-OldFiles {
        param([string]$path)

        $filesToDelete = Get-ChildItem -Path $path -Recurse -File | 
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$DaysToKeep) }

        $deletedCount = 0
        foreach ($file in $filesToDelete) {
            try {
                Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                $deletedCount++
                Write-Log "Deleted: $($file.FullName)"
            }
            catch {
                Write-Log "Error deleting $($file.FullName): $_"
            }
        }
        
        return $deletedCount
    }

    # Delete old screenshots and screen recordings
    $deletedScreenshotsCount = Delete-OldFiles -path $screenshotsPath
    $deletedScreenRecordingsCount = Delete-OldFiles -path $screenRecordingsPath

    Write-Log "Cleanup completed. Deleted: $deletedScreenshotsCount screenshots and $deletedScreenRecordingsCount screen recordings older than $DaysToKeep days."
}
catch {
    Write-Log "Error: $_"
}
