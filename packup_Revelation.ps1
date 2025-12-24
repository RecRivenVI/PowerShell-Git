$OriginUrl = "https://github.com/HaringPro/Revelation.git"
$ZipName = "Revelation Dev Packup"

$OriginParts = $OriginUrl -split "/"
$OriginOwner = $OriginParts[-2]
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

$CommitDate = git log -1 --author="$OriginOwner" --pretty=format:"%ad" --date=format:'%Y-%m-%d'
if (Test-Path "..\$ZipName $CommitDate.zip") {
    Remove-Item "..\$ZipName $CommitDate.zip"
}
& "C:\Program Files\7-Zip\7z.exe" a -tzip "..\$ZipName $CommitDate.zip" ".\shaders"

pause
