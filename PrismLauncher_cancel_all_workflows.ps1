$Repo = "RecRivenVI/PrismLauncher"
$Token = gh auth token

$runs = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/actions/runs" `
    -Headers @{ Authorization = "token $Token"; "User-Agent" = "PowerShell" }

foreach ($run in $runs.workflow_runs) {

    if ($run.status -eq "in_progress" -or $run.status -eq "queued") {
        Write-Host "取消运行: $($run.id) ($($run.path))"
        Invoke-RestMethod -Method Post `
            -Uri "https://api.github.com/repos/$Repo/actions/runs/$($run.id)/cancel" `
            -Headers @{ Authorization = "token $Token"; "User-Agent" = "PowerShell" }
    }
}

pause
