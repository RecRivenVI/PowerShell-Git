$Repo = "RecRivenVI/PrismLauncher"
$Token = gh auth token

$runs = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/actions/runs" `
    -Headers @{ Authorization = "token $Token"; "User-Agent" = "PowerShell" }

foreach ($run in $runs.workflow_runs) {

    $workflowPath = $run.path

    $isRelease = $workflowPath -like "*release.yml"

    if (-not $isRelease) {
        if ($run.status -eq "in_progress" -or $run.status -eq "queued") {
            Write-Host "取消运行: $($run.id) ($workflowPath)"
            Invoke-RestMethod -Method Post `
                -Uri "https://api.github.com/repos/$Repo/actions/runs/$($run.id)/cancel" `
                -Headers @{ Authorization = "token $Token"; "User-Agent" = "PowerShell" }
        }
    }
    else {
        Write-Host "保留 release.yml 运行: $($run.id)"
    }
}

pause
