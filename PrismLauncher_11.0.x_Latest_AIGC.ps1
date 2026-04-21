$OriginUrl = "https://github.com/RecRivenVI/PrismLauncher.git"
$UpstreamUrl = "https://github.com/PrismLauncher/PrismLauncher.git"
$Repo = "RecRivenVI/PrismLauncher"
$Branch = "develop"
$TagName = "11.0"

$WorkDir = Join-Path $env:TEMP "PrismLauncher_Sync_$(Get-Date -Format 'yyyyMMddHHmm')"
$RepoPath = Join-Path $WorkDir "PrismLauncher"

function Invoke-Git {
    param([string]$Command)
    Write-Host "执行: git $Command" -ForegroundColor Cyan
    Invoke-Expression "git $Command"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Git 命令失败。"
        return $false
    }
    return $true
}

if (!(Test-Path $WorkDir)) { New-Item -ItemType Directory -Path $WorkDir | Out-Null }
Set-Location $WorkDir

Write-Host "正在拉取干净的仓库到临时目录: $WorkDir" -ForegroundColor Gray
if (!(Invoke-Git "clone --depth 1 $OriginUrl")) { pause; exit } # 使用 --depth 1 加快速度

Set-Location $RepoPath

$Remotes = git remote
if (!($Remotes -contains "upstream")) {
    Invoke-Git "remote add upstream $UpstreamUrl"
}

Invoke-Git "fetch upstream --depth 1"
Invoke-Git "checkout $Branch"
Invoke-Git "reset --hard upstream/$Branch"
Invoke-Git "push origin $Branch --force"

Write-Host "正在重置 Tag [$TagName] 以触发编译..." -ForegroundColor Yellow
git tag -d $TagName 2>$null
Invoke-Git "push origin :refs/tags/$TagName"
Invoke-Git "tag $TagName"
Invoke-Git "push origin $TagName"

Write-Host "等待 GitHub API 响应 (5s)..." -ForegroundColor Gray
Start-Sleep -Seconds 5

$Token = gh auth token
if (!$Token) {
    Write-Error "未检测到 gh auth token"
    pause; exit
}

$Headers = @{ Authorization = "token $Token"; "User-Agent" = "PowerShell"; "Accept" = "application/vnd.github+json" }
$runs = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/actions/runs" -Headers $Headers

foreach ($run in $runs.workflow_runs) {
    if ($run.path -notlike "*release.yml" -and ($run.status -eq "in_progress" -or $run.status -eq "queued")) {
        Write-Host "取消无关任务: $($run.id)" -ForegroundColor Gray
        try { Invoke-RestMethod -Method Post -Uri "https://api.github.com/repos/$Repo/actions/runs/$($run.id)/cancel" -Headers $Headers } catch {}
    }
}

Write-Host "`n所有操作已完成！按任意键清理本地文件并退出..." -ForegroundColor Green
pause

Set-Location $env:TEMP
Write-Host "正在删除临时文件: $WorkDir" -ForegroundColor DarkGray
Remove-Item -Path $WorkDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "清理完毕。" -ForegroundColor White