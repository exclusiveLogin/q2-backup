<#
.SYNOPSIS
  Показать последний релиз прошивки QIDI Q2 из kokoc26/qidi-q2-fw.
.EXAMPLE
  .\check-latest.ps1
  .\check-latest.ps1 -Json
#>
param(
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
$api = 'https://api.github.com/repos/kokoc26/qidi-q2-fw/releases/latest'
$headers = @{
    'Accept'     = 'application/vnd.github+json'
    'User-Agent' = 'q2-backup-fw-check'
}

$rel = Invoke-RestMethod -Uri $api -Headers $headers -TimeoutSec 30
$asset = $rel.assets |
    Where-Object { $_.name -match '\.zip$' } |
    Sort-Object size -Descending |
    Select-Object -First 1

$info = [ordered]@{
    tag          = $rel.tag_name
    name         = $rel.name
    published_at = $rel.published_at
    html_url     = $rel.html_url
    body_preview = if ($rel.body) { ($rel.body -split "`n" | Select-Object -First 8) -join "`n" } else { '' }
    asset_name   = if ($asset) { $asset.name } else { $null }
    asset_size_mb = if ($asset) { [math]::Round($asset.size / 1MB, 1) } else { $null }
    download_url = if ($asset) { $asset.browser_download_url } else { $null }
}

if ($Json) {
    $info | ConvertTo-Json -Depth 4
    return
}

Write-Host "Latest QIDI Q2 firmware (kokoc26/qidi-q2-fw)"
Write-Host ("  Tag:       {0}" -f $info.tag)
Write-Host ("  Name:      {0}" -f $info.name)
Write-Host ("  Published: {0}" -f $info.published_at)
Write-Host ("  Release:   {0}" -f $info.html_url)
if ($info.asset_name) {
    Write-Host ("  Asset:     {0} ({1} MB)" -f $info.asset_name, $info.asset_size_mb)
    Write-Host ("  Download:  {0}" -f $info.download_url)
} else {
    Write-Host "  Asset:     (no .zip in release)"
}
