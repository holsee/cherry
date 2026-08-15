# cherry installer, https://cherrybomb.dev/install.ps1 (ADR 0007)
# Resolves the latest stable release, verifies the SHA-256 checksum,
# installs to $env:LOCALAPPDATA\cherry\bin (or $env:CHERRY_INSTALL_DIR).
$ErrorActionPreference = "Stop"

$repo = "holsee/cherry"
$asset = "cherry-windows-x86_64.exe"
$installDir = if ($env:CHERRY_INSTALL_DIR) { $env:CHERRY_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA "cherry\bin" }

# Prefer the latest stable release; while only prereleases exist,
# releases/latest 404s, so fall back to the newest release of any kind.
try {
  $tag = (Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest").tag_name
} catch {
  $releases = Invoke-RestMethod "https://api.github.com/repos/$repo/releases?per_page=1"
  if (-not $releases) { throw "no releases found for $repo" }
  $tag = $releases[0].tag_name
}

$base = "https://github.com/$repo/releases/download/$tag"
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $tmp | Out-Null

try {
  Write-Host "downloading $asset ($tag)..."
  Invoke-WebRequest -Uri "$base/$asset" -OutFile (Join-Path $tmp $asset)
  Invoke-WebRequest -Uri "$base/SHA256SUMS" -OutFile (Join-Path $tmp "SHA256SUMS")

  Write-Host "verifying checksum..."
  $line = Select-String -Path (Join-Path $tmp "SHA256SUMS") -Pattern ([regex]::Escape($asset)) | Select-Object -First 1
  if (-not $line) { throw "$asset not found in SHA256SUMS" }
  $expected = ($line.Line -split "\s+")[0].ToLower()
  $actual = (Get-FileHash -Algorithm SHA256 (Join-Path $tmp $asset)).Hash.ToLower()
  if ($expected -ne $actual) {
    throw "checksum mismatch for ${asset}: expected $expected, got $actual"
  }

  New-Item -ItemType Directory -Force -Path $installDir | Out-Null
  Copy-Item (Join-Path $tmp $asset) (Join-Path $installDir "cherry.exe") -Force

  Write-Host "installed cherry to $installDir\cherry.exe"
  if (($env:Path -split ";") -notcontains $installDir) {
    Write-Host "note: add $installDir to your PATH"
  }
  & (Join-Path $installDir "cherry.exe") version
}
finally {
  Remove-Item -Recurse -Force $tmp
}
