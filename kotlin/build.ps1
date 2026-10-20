$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

Remove-Item -Recurse -Force classes -ErrorAction SilentlyContinue
Remove-Item -Force plugin.jar -ErrorAction SilentlyContinue
New-Item -ItemType Directory classes | Out-Null

$sources = Get-ChildItem hosihikari -Filter *.java | ForEach-Object { $_.FullName }
javac --release 21 -d classes $sources
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

kotlinc -jvm-target 21 -cp classes -include-runtime -d plugin.jar src/MyKotlinPlugin.kt
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

jar uf plugin.jar -C classes .
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item -Recurse -Force classes
