$OriginUrl = "https://github.com/RecRivenVI/PrismLauncher.git"
$UpstreamUrl = "https://github.com/PrismLauncher/PrismLauncher.git"

$OriginParts = $OriginUrl -split "/"
$OriginRepository = ($OriginParts[-1] -replace '\.git$', '')
$OriginBranch = "develop"

$Path = ".\$OriginRepository"

$UpstreamBranch = "develop"


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

git remote remove upstream
git remote add upstream $UpstreamUrl
git fetch upstream
git checkout $OriginBranch
git reset --hard upstream/$UpstreamBranch

git push origin $OriginBranch --force

git tag 11.0.3 --force
git push origin 11.0.3 --force

pause
