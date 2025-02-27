param (
    [string]$ServerListPath,
    [string]$Username,
    [string]$Password
)

$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)

$InputDirectory = Split-Path $Script:MyInvocation.Mycommand.path
$Servers = Get-Content $ServerListPath

$Output = @()
$Output = Invoke-Command -cn $Servers -Credential $cred {
    $Results = @{} | Select Days, Hours, Minutes

    $OS = New-TimeSpan -Seconds (Get-WmiObject -Class Win32_PerfFormattedData_PerfOS_System).SystemUpTime -ErrorAction SilentlyContinue
    if (($OS -ne $null) -and ($OS.Length -ne 0)) {
        $Results.Days = $OS.Days
        $Results.Hours = $OS.Hours
        $Results.Minutes = $OS.Minutes 
    }
    else {
        $Results.Days = "The remote server machine does not exist or is unavailable"
        $Results.Hours = "-"
        $Results.Minutes = "-"
    }

    $Results
} | Select-Object @{n='ServerName';e={$_.pscomputername}}, Days, Hours, Minutes

$Output | Export-Csv "$InputDirectory\Uptime.csv" -NoTypeInformation
Write-Host " Uptime report generated " -ForegroundColor Yellow
