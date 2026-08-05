#Requires -Version 5.1
<#
.SYNOPSIS
  Copy latest board HTML into this Pages repo and push to GitHub.
#>
$ErrorActionPreference = "Stop"

$PagesDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceHtml = "C:\ai\reports\research-board\中信建投研究所晨报及研报看板.html"
$DestHtml = Join-Path $PagesDir "index.html"

if (-not (Test-Path -LiteralPath $SourceHtml)) {
  Write-Error "Source board not found: $SourceHtml`nRun build_board.py first."
}

Copy-Item -LiteralPath $SourceHtml -Destination $DestHtml -Force
# Ensure Pages serves files as-is (no Jekyll)
$nojekyll = Join-Path $PagesDir ".nojekyll"
if (-not (Test-Path $nojekyll)) {
  Set-Content -Path $nojekyll -Value "" -Encoding ascii
}

Set-Location $PagesDir
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Error "Not a git repo: $PagesDir"
}

git add index.html .nojekyll .github/workflows/deploy-pages.yml README.md
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
  Write-Host "Add remote then push, e.g.:"
  Write-Host "  git remote add origin https://github.com/YOUR_USER/csc-research-board.git"
  Write-Host "  git push -u origin main"
  exit 0
}

git push
Write-Host "Published. Recipients can refresh the GitHub Pages URL."
