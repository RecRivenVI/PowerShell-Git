$OriginUrl = "https://github.com/RecRivenVI/PrismLauncher.git"
$UpstreamUrl = "https://github.com/PrismLauncher/PrismLauncher.git"

$OriginParts = $OriginUrl -split "/"
$OriginRepository = ($OriginParts[-1] -replace '\.git$', '')
$OriginBranch = "develop"

$Path = ".\$OriginRepository"

$UpstreamBranch = "develop"

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

git remote remove upstream 2>&1 | Out-Null
git remote add upstream $UpstreamUrl
git fetch upstream
git checkout $OriginBranch
git reset --hard upstream/$UpstreamBranch

function Invoke-CherryPickPr($PrNumber) {
    git fetch upstream pull/$PrNumber/head:pr-$PrNumber
    foreach ($c in $(git rev-list --reverse pr-$PrNumber ^$OriginBranch)) {
        $ad = git show -s --format='%aD' $c
        $env:GIT_COMMITTER_DATE = $ad
        git cherry-pick $c
        if ($LASTEXITCODE -ne 0) {
            break
        }
    }
}
<# 
Invoke-CherryPickPr
 #>
git push origin $OriginBranch --force

git tag 10.0 --force
git push origin 10.0 --force

python "D:\GitHub\git-tools\git-restore-mtime"

pause
