<#
.SYNOPSIS
  Скачать последний ZIP прошивки QIDI Q2 из kokoc26/qidi-q2-fw Releases.
.EXAMPLE
  .\download-latest.ps1
  .\download-latest.ps1 -Force
  .\download-latest.ps1 -Tag V01.01.02.04
#>
param(
    [string]$Tag,
    [string]$OutDir = (Join-Path $PSScriptRoot 'downloads'),
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$headers = @{
    'Accept'     = 'application/vnd.github+json'
    'User-Agent' = 'q2-backup-fw-download'
}

if ($Tag) {
    $api = "https://api.github.com/repos/kokoc26/qidi-q2-fw/releases/tags/$Tag"
    Write-Host "Fetching release tag: $Tag"
} else {
    $api = 'https://api.github.com/repos/kokoc26/qidi-q2-fw/releases/latest'
    Write-Host 'Fetching latest release...'
}

$rel = Invoke-RestMethod -Uri $api -Headers $headers -TimeoutSec 30
$asset = $rel.assets |
    Where-Object { $_.name -match '\.zip$' } |
    Sort-Object size -Descending |
    Select-Object -First 1

if (-not $asset) {
    throw "No .zip asset in release $($rel.tag_name)"
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$dest = Join-Path $OutDir $asset.name

Write-Host ("Tag:      {0}" -f $rel.tag_name)
Write-Host ("Asset:    {0} ({1:N1} MB)" -f $asset.name, ($asset.size / 1MB))
Write-Host ("URL:      {0}" -f $asset.browser_download_url)
Write-Host ("Save to:  {0}" -f $dest)

if ((Test-Path $dest) -and -not $Force) {
    $local = (Get-Item $dest).Length
    if ($local -eq $asset.size) {
        Write-Host 'Already downloaded (size match). Use -Force to re-download.'
        Write-Host $dest
        return
    }
    Write-Host "Local file size mismatch ($local vs $($asset.size)), re-downloading..."
}

Write-Host 'Downloading...'
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $dest -TimeoutSec 600 -UseBasicParsing

$got = (Get-Item $dest).Length
if ($got -ne $asset.size) {
    throw "Download size mismatch: got $got, expected $($asset.size)"
}

# sidecar meta
$meta = [ordered]@{
    downloaded_at  = (Get-Date).ToString('o')
    tag            = $rel.tag_name
    release_url    = $rel.html_url
    asset_name     = $asset.name
    asset_size     = $asset.size
    download_url   = $asset.browser_download_url
    local_path     = $dest
}
$metaPath = Join-Path $OutDir ("{0}.json" -f [IO.Path]::GetFileNameWithoutExtension($asset.name))
$meta | ConvertTo-Json | Out-File $metaPath -Encoding utf8

Write-Host ("OK  {0:N1} MB -> {1}" -f ($got / 1MB), $dest)
Write-Host ("Meta {0}" -f $metaPath)
