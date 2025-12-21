$OriginUrl = "https://github.com/RecRivenVI/DLL_Injection_XiaoaiAgent.git"

$OriginParts = $OriginUrl -split "/"
$OriginRepository = ($OriginParts[-1] -replace '\.git$', '')

$Path = ".\$OriginRepository"

$env:HTTP_PROXY = "http://127.0.0.1:7897"
$env:HTTPS_PROXY = "http://127.0.0.1:7897"

if (Test-Path $Path) {
    Set-Location $Path
}
else {
    git clone $OriginUrl
    if ($LASTEXITCODE -ne 0) {
        pause
        exit
    }
    Set-Location $Path
}

$OriginDefaultBranch = git remote show origin | Select-String "HEAD branch" | ForEach-Object { ($_ -split ":")[1].Trim() }

git fetch origin
git checkout $OriginDefaultBranch
git reset --hard origin/$OriginDefaultBranch

python "D:\GitHub\git-tools\git-restore-mtime"

pause
