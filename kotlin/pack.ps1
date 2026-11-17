# Pack this runtime package with the framework's packer. The packer writes the
# LeviLamina manifest.json envelope next to hosihikari.json.
#
# A package still on the 1.x manifest.json migrates first, in the same command.
# Run `pwsh ./pack.ps1 -MigrateOnly` to rewrite the metadata and stop there.
#
# Build first (./build.sh or ./build.ps1): the packer copies the working tree.
# Requires a sibling PluginManager checkout, or HOSIHIKARI_PLUGINMANAGER.
param(
    [switch]$MigrateOnly
)
$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$core = if ($env:HOSIHIKARI_PLUGINMANAGER) {
    $env:HOSIHIKARI_PLUGINMANAGER
} else {
    Join-Path (Split-Path (Split-Path $here -Parent) -Parent) 'PluginManager'
}
$tool = Join-Path $core 'tools\Pack\Hosihikari.Plugin.Pack.csproj'
if (-not (Test-Path $tool)) {
    throw ("Core packer not found: {0}. Run with a sibling Hosihikari.PluginManager checkout, " +
        'or set HOSIHIKARI_PLUGINMANAGER.') -f $tool
}

# 旧包在包根上还留着 manifest.json；migrate 就地换掉（ADR-0058）。
if (Test-Path (Join-Path $here 'manifest.json')) {
    if (Test-Path (Join-Path $here 'hosihikari.json')) {
        throw 'manifest.json and hosihikari.json both exist; delete the stale manifest.json first'
    }

    & dotnet run --project $tool -c Release -- migrate $here
    if ($LASTEXITCODE -ne 0) { throw 'the migration failed' }
    Write-Host 'migrated manifest.json to hosihikari.json; review it before packing'
    if ($MigrateOnly) { return }
}

if ($MigrateOnly) {
    Write-Host 'nothing to migrate: hosihikari.json is already in place'
    return
}

# 打包器拒绝输出目录与源目录相交；先复制到临时目录，排除仓库元数据与旧产物。
# TEMP 是 Windows 的形状；Linux / macOS 上按平台解析临时目录。
$stage = Join-Path ([System.IO.Path]::GetTempPath()) ("hosihikari-template-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force $stage | Out-Null
try {
    Get-ChildItem -Force $here |
        Where-Object { $_.Name -notin @('.git', 'dist', 'data', 'bin', 'obj') } |
        Copy-Item -Destination $stage -Recurse -Force

    dotnet run --project $tool -c Release -- pack-plugin $stage (Join-Path $here 'hosihikari.json') (Join-Path $here 'dist')
    # 原生命令非零退出不会自己抛：PowerShell 默认不把 $LASTEXITCODE 当错误。
    if ($LASTEXITCODE -ne 0) { throw 'the packer failed' }
} finally {
    if (Test-Path $stage) {
        Remove-Item -Recurse -Force $stage -ErrorAction SilentlyContinue
    }
}
