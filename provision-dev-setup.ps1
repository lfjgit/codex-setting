$ErrorActionPreference = 'Stop'

function Write-Step($message) {
    Write-Host ""
    Write-Host "==> $message" -ForegroundColor Cyan
}

function Refresh-ProcessPath {
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($machinePath -and $userPath) {
        $env:Path = "$machinePath;$userPath"
    } elseif ($machinePath) {
        $env:Path = $machinePath
    } elseif ($userPath) {
        $env:Path = $userPath
    }
}

function Ensure-WingetPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    $isInstalled = $false
    try {
        $listOutput = winget list --exact --id $Id --accept-source-agreements 2>$null | Out-String
        if ($listOutput -match [regex]::Escape($Id)) {
            $isInstalled = $true
        }
    } catch {
        $isInstalled = $false
    }

    if ($isInstalled) {
        Write-Host "Already installed: $Id"
        return
    }

    Write-Host "Installing: $Id"
    winget install --exact --id $Id --silent --accept-package-agreements --accept-source-agreements
}

function Get-CodeCommand {
    $candidates = @(
        (Get-Command code.cmd -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue),
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
        "${env:ProgramFiles}\Microsoft VS Code\bin\code.cmd",
        "${env:ProgramFiles(x86)}\Microsoft VS Code\bin\code.cmd"
    ) | Where-Object { $_ -and (Test-Path $_) }

    return $candidates | Select-Object -First 1
}

function Get-NpmCommand {
    $candidates = @(
        (Get-Command npm.cmd -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue),
        "${env:ProgramFiles}\nodejs\npm.cmd",
        "${env:ProgramFiles(x86)}\nodejs\npm.cmd"
    ) | Where-Object { $_ -and (Test-Path $_) }

    return $candidates | Select-Object -First 1
}

function Install-NpmGlobal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName
    )

    $npm = Get-NpmCommand
    if (-not $npm) {
        throw "npm was not found after Node.js installation."
    }

    & $npm install -g $PackageName
}

function Install-CodeExtension {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExtensionId
    )

    $code = Get-CodeCommand
    if (-not $code) {
        throw "VS Code CLI was not found after installation."
    }

    & $code --install-extension $ExtensionId --force
}

Write-Step "Installing base packages with winget"
Ensure-WingetPackage -Id 'OpenJS.NodeJS.LTS'
Ensure-WingetPackage -Id 'Git.Git'
Ensure-WingetPackage -Id 'Microsoft.VisualStudioCode'
Refresh-ProcessPath

Write-Step "Installing Codex CLI and Feishu CLI"
Install-NpmGlobal -PackageName '@openai/codex'
Install-NpmGlobal -PackageName '@larksuite/cli'

Write-Step "Installing VS Code extensions"
$extensions = @(
    'MS-CEINTL.vscode-language-pack-zh-hans',
    'eamodio.gitlens',
    'usernamehw.errorlens',
    'yzhang.markdown-all-in-one',
    'DavidAnson.vscode-markdownlint',
    'esbenp.prettier-vscode',
    'ms-toolsai.datawrangler',
    'ritwickdey.LiveServer',
    'OpenAI.chatgpt'
)

foreach ($extension in $extensions) {
    Install-CodeExtension -ExtensionId $extension
}

Write-Step "Writing VS Code user settings"
$codeUserDir = Join-Path $env:APPDATA 'Code\User'
New-Item -ItemType Directory -Path $codeUserDir -Force | Out-Null

$settings = [ordered]@{
    'editor.fontFamily' = "'Cascadia Code', Consolas, 'Courier New', monospace"
    'editor.fontLigatures' = $true
    'editor.fontSize' = 14
    'editor.lineHeight' = 1.6
    'editor.minimap.enabled' = $false
    'editor.wordWrap' = 'on'
    'editor.bracketPairColorization.enabled' = $true
    'editor.guides.bracketPairs' = 'active'
    'editor.formatOnSave' = $true
    'editor.stickyScroll.enabled' = $true
    'files.autoSave' = 'afterDelay'
    'files.autoSaveDelay' = 1200
    'files.trimTrailingWhitespace' = $true
    'files.insertFinalNewline' = $true
    'workbench.startupEditor' = 'none'
    'workbench.editor.enablePreview' = $false
    'window.commandCenter' = $false
    'window.zoomLevel' = 0
    'workbench.colorTheme' = 'Default Light Modern'
    'terminal.integrated.defaultProfile.windows' = 'PowerShell'
    'terminal.integrated.fontFamily' = 'Cascadia Code'
    'git.autofetch' = $true
    'git.enableSmartCommit' = $true
    'git.confirmSync' = $false
    'git.openRepositoryInParentFolders' = 'always'
    'markdown.preview.scrollEditorWithPreview' = $true
    'markdown.preview.scrollPreviewWithEditor' = $true
    'extensions.autoCheckUpdates' = $true
    'extensions.autoUpdate' = $true
    'telemetry.telemetryLevel' = 'error'
    'security.workspace.trust.untrustedFiles' = 'open'
}

$settings | ConvertTo-Json -Depth 10 | Set-Content -Path (Join-Path $codeUserDir 'settings.json') -Encoding utf8
'{"locale":"zh-cn"}' | Set-Content -Path (Join-Path $codeUserDir 'locale.json') -Encoding utf8

Write-Step "Applying Git global quality-of-life settings"
git config --global init.defaultBranch main
git config --global fetch.prune true
git config --global pull.rebase false
git config --global rebase.autostash true
git config --global credential.helper manager-core
git config --global core.editor "code --wait"
git config --global core.longpaths true
git config --global merge.conflictstyle zdiff3

Write-Step "Updating Codex config for a token-saving default profile"
$codexDir = Join-Path $env:USERPROFILE '.codex'
New-Item -ItemType Directory -Path $codexDir -Force | Out-Null
$codexConfigPath = Join-Path $codexDir 'config.toml'
$existingCodexConfig = ''
if (Test-Path $codexConfigPath) {
    $existingCodexConfig = Get-Content $codexConfigPath -Raw
}

$managedBlock = @'
model = "gpt-5-mini"
model_reasoning_effort = "low"
approval_policy = "on-request"
sandbox_mode = "workspace-write"

[profiles.deep]
model = "gpt-5"
model_reasoning_effort = "medium"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
'@

$startMarker = '# codex-managed-start'
$endMarker = '# codex-managed-end'
$wrappedBlock = "$startMarker`r`n$managedBlock`r`n$endMarker"

if ($existingCodexConfig -match [regex]::Escape($startMarker) -and $existingCodexConfig -match [regex]::Escape($endMarker)) {
    $pattern = [regex]::Escape($startMarker) + '.*?' + [regex]::Escape($endMarker)
    $updatedCodexConfig = [regex]::Replace($existingCodexConfig, $pattern, $wrappedBlock, 'Singleline')
} elseif ([string]::IsNullOrWhiteSpace($existingCodexConfig)) {
    $updatedCodexConfig = $wrappedBlock
} else {
    $updatedCodexConfig = $existingCodexConfig.TrimEnd() + "`r`n`r`n" + $wrappedBlock + "`r`n"
}

$updatedCodexConfig | Set-Content -Path $codexConfigPath -Encoding utf8

Write-Step "Installing Lark skills for Codex if available"
$npxCommand = Get-Command npx.cmd -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue
if (-not $npxCommand) {
    $npxCommand = "${env:ProgramFiles}\nodejs\npx.cmd"
}

if ($npxCommand -and (Test-Path $npxCommand)) {
    try {
        & $npxCommand skills add larksuite/cli --all -y -g
    } catch {
        Write-Warning "Skipped larksuite skill install: $($_.Exception.Message)"
    }
} else {
    Write-Warning "npx not found, skipped larksuite skill install."
}

Write-Step "Collecting versions"
$versionReport = [ordered]@{}
$versionReport.Node = (& (Get-Command node.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source) --version) 2>$null
$versionReport.Npm = (& (Get-NpmCommand) --version) 2>$null
$versionReport.Git = (& git --version) 2>$null
$versionReport.Codex = (& codex --version) 2>$null
$larkCommand = Get-Command lark-cli.cmd,lark-cli,lark.cmd,lark -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source
if ($larkCommand) {
    $versionReport.LarkCli = (& $larkCommand --version) 2>$null
} else {
    $versionReport.LarkCli = $null
}
$versionReport.VSCode = (& (Get-CodeCommand) --version | Select-Object -First 1) 2>$null

$versionReport | ConvertTo-Json -Depth 5 | Set-Content -Path (Join-Path $PSScriptRoot 'provision-report.json') -Encoding utf8
Write-Host ""
Write-Host "Provisioning complete. Report written to provision-report.json" -ForegroundColor Green
