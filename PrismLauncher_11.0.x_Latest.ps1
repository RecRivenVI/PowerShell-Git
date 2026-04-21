$OriginUrl = "https://github.com/RecRivenVI/PrismLauncher.git"
$UpstreamUrl = "https://github.com/PrismLauncher/PrismLauncher.git"

$OriginParts = $OriginUrl -split "/"
$OriginRepository = ($OriginParts[-1] -replace '\.git$', '')
$OriginBranch = "develop"

$Path = ".\$OriginRepository"

$UpstreamBranch = "develop"
$Tag = (gh api repos/PrismLauncher/PrismLauncher/milestones --jq '.[].title' | Sort-Object { [version]$_ } | Select-Object -First 1)

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
<# 
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

Invoke-CherryPickPr 4470
 #>
git push origin $OriginBranch --force

git tag $Tag --force
git push origin $Tag --force

pause
