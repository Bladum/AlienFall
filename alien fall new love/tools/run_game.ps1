param(
    [switch]$Test,
    [switch]$TestWatch,
    [string]$TestFile,
    [switch]$Debug,
    [switch]$Console
)

# Set the Love2D executable path - always use console version
$lovePath = "C:\Program Files\LOVE\lovec.exe"

# Build environment variables for test mode
$envVars = @{}

if ($Test -or $TestWatch -or $TestFile) {
    $envVars["LOVE_TEST_MODE"] = "true"
}

if ($TestWatch) {
    $envVars["LOVE_TEST_WATCH"] = "true"
}

if ($TestFile) {
    $envVars["LOVE_TEST_FILE"] = $TestFile
}

# Determine which executable to use
$exe = if ($Debug -or $Console) { "lovec.exe" } else { "love.exe" }
$lovePath = "C:\Program Files\LOVE\$exe"

# Run the game with appropriate environment variables
if ($envVars.Count -gt 0) {
    Write-Host "Running Alien Fall with test mode enabled..."
    Write-Host "Environment variables:"
    $envVars.GetEnumerator() | ForEach-Object { Write-Host "  $($_.Key)=$($_.Value)" }

    # Set environment variables and run
    $envVars.GetEnumerator() | ForEach-Object {
        [Environment]::SetEnvironmentVariable($_.Key, $_.Value, "Process")
    }

    & $lovePath .
} else {
    Write-Host "Running Alien Fall..."
    & $lovePath .
}