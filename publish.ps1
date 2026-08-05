#Requires -Version 5.1
<#
.SYNOPSIS
  Copy latest board HTML into this Pages repo and push to GitHub.
#>
$ErrorActionPreference = "Stop"

$PagesDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BoardsJson = "C:\Users\TU\.cursor\skills\research-board\config\boards.json"
$DestHtml = Join-Path $PagesDir "index.html"
$PathFile = Join-Path $env:TEMP "csc-board-out-html-path.txt"

& python -X utf8 -c @"
import json
from pathlib import Path
cfg = json.loads(Path(r'$BoardsJson').read_text(encoding='utf-8'))
src = Path(cfg['boards']['csc']['out_html'])
Path(r'$PathFile').write_text(str(src.resolve()), encoding='utf-8')
print('ok' if src.is_file() else 'missing')
"@
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$SourceHtml = Get-Content -LiteralPath $PathFile -Encoding utf8 -Raw
$SourceHtml = $SourceHtml.Trim()

if (-not (Test-Path -LiteralPath $SourceHtml)) {
  Write-Error "Source board not found: $SourceHtml`nRun build_board.py first."
}

Copy-Item -LiteralPath $SourceHtml -Destination $DestHtml -Force
Write-Host "Copied board -> index.html ($((Get-Item -LiteralPath $DestHtml).Length) bytes)"

$nojekyll = Join-Path $PagesDir ".nojekyll"
if (-not (Test-Path $nojekyll)) {
  Set-Content -Path $nojekyll -Value "" -Encoding ascii
}

Set-Location $PagesDir
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Error "Not a git repo: $PagesDir"
}

git add index.html .nojekyll .github/workflows/deploy-pages.yml README.md publish.ps1
$status = git status --porcelain
if (-not $status) {
  Write-Host "No changes to publish (index.html already up to date)."
  exit 0
}

$stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
git commit -m "Update board $stamp"
$remote = git remote 2>$null
if (-not $remote) {
  Write-Host "Committed locally, but no git remote yet."
  Write-Host "  git remote add origin https://github.com/JessieWhale/citic-research-board.git"
  Write-Host "  git push -u origin main"
  exit 0
}

git push
Write-Host "Published. Recipients can refresh the GitHub Pages URL."
