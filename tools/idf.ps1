[CmdletBinding()]
param(
    [ValidateSet('build', 'flash', 'monitor', 'reconfigure', 'clean', 'fullclean')]
    [string]$Action = 'build',
    [string]$Port = 'COM5',
    [string]$IdfPath = $env:IDF_PATH,
    [string]$IdfToolsPath = $env:IDF_TOOLS_PATH,
    [int]$Jobs = 0
)

$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$BuildDir = Join-Path $RepoRoot 'build\idf'
$SdkConfig = Join-Path $RepoRoot 'build\sdkconfig'

if ([string]::IsNullOrWhiteSpace($IdfPath)) {
    $IdfPath = 'E:\Espressif\esp-idf-v5.5.4'
}
if ([string]::IsNullOrWhiteSpace($IdfToolsPath)) {
    $IdfToolsPath = 'E:\Espressif\.espressif'
}

$ExportScript = Join-Path $IdfPath 'export.ps1'
if (-not (Test-Path -LiteralPath $ExportScript)) {
    throw "ESP-IDF export script not found: $ExportScript"
}

New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null

$env:IDF_TOOLS_PATH = $IdfToolsPath
. $ExportScript

function Assert-NativeSuccess {
    param([string]$Step)
    if ($LASTEXITCODE -ne 0) {
        throw "$Step failed with exit code $LASTEXITCODE"
    }
}

$IdfArgs = @('-B', $BuildDir, '-D', "SDKCONFIG=$SdkConfig")

switch ($Action) {
    'build' {
        idf.py @IdfArgs reconfigure
        Assert-NativeSuccess 'idf.py reconfigure'
        if ($Jobs -le 0) {
            $Jobs = [int]$env:NUMBER_OF_PROCESSORS
            if ($Jobs -le 0) { $Jobs = 4 }
        }
        ninja -C $BuildDir -j $Jobs
        Assert-NativeSuccess 'ninja build'
    }
    'flash' {
        idf.py @IdfArgs -p $Port flash
        Assert-NativeSuccess 'idf.py flash'
    }
    'monitor' {
        idf.py @IdfArgs -p $Port monitor
        Assert-NativeSuccess 'idf.py monitor'
    }
    'reconfigure' {
        idf.py @IdfArgs reconfigure
        Assert-NativeSuccess 'idf.py reconfigure'
    }
    'clean' {
        idf.py @IdfArgs clean
        Assert-NativeSuccess 'idf.py clean'
    }
    'fullclean' {
        idf.py @IdfArgs fullclean
        Assert-NativeSuccess 'idf.py fullclean'
    }
}
