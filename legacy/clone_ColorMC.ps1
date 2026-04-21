$OriginUrl = "https://github.com/Coloryr/ColorMC.git"

$OriginParts = $OriginUrl -split "/"
$OriginRepository = ($OriginParts[-1] -replace '\.git$', '')

$Path = ".\$OriginRepository"


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



pause
