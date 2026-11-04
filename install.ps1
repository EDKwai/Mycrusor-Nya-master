$ErrorActionPreference = "Stop"
$Src = $PSScriptRoot
$CursorHome = Join-Path $env:USERPROFILE ".cursor"
$Dest = Join-Path $CursorHome "plugins\local\cursor-neko-maid"
$UserRulesDir = Join-Path $CursorHome "rules"
$HooksPath = Join-Path $CursorHome "hooks.json"

if (-not (Test-Path (Join-Path $Src ".cursor-plugin\plugin.json"))) {
    Write-Host "找不到 .cursor-plugin/plugin.json，请在解压后的插件根目录运行" -ForegroundColor Red
    exit 1
}

$node = (Get-Command node -ErrorAction SilentlyContinue).Source
if (-not $node) { $node = "C:\Program Files\nodejs\node.exe" }
if (-not (Test-Path $node)) {
    Write-Host "未找到 node.exe，hook 无法挂到所有对话。仍会安装规则文件。" -ForegroundColor Yellow
    $node = $null
}

New-Item -ItemType Directory -Force -Path (Split-Path $Dest) | Out-Null
if (Test-Path $Dest) { Remove-Item -Recurse -Force $Dest }
Copy-Item -Recurse -Force $Src $Dest
Write-Host "插件 -> $Dest"

New-Item -ItemType Directory -Force -Path $UserRulesDir | Out-Null
Copy-Item -Force (Join-Path $Src "rules\master-nya.mdc") (Join-Path $UserRulesDir "master-nya.mdc")
Write-Host "用户规则文件 -> $UserRulesDir\master-nya.mdc"

if ($node) {
    $hookJs = Join-Path $Dest "hooks\hook.js"
    $backup = Join-Path $CursorHome ("backups\cursor-neko-maid-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
    New-Item -ItemType Directory -Force -Path $backup | Out-Null
    if (Test-Path $HooksPath) {
        Copy-Item $HooksPath (Join-Path $backup "hooks.json") -Force
    }

    $raw = '{"version":1,"hooks":{}}'
    if (Test-Path $HooksPath) { $raw = [System.IO.File]::ReadAllText($HooksPath) }
    $obj = $raw | ConvertFrom-Json
    if (-not $obj.hooks) {
        $obj | Add-Member -NotePropertyName hooks -NotePropertyValue ([pscustomobject]@{}) -Force
    }

    function Set-NekoHook([string]$EventName, [string]$Mode) {
        $cmd = '"' + $node + '" "' + $hookJs + '" ' + $Mode
        $kept = @()
        $prop = $obj.hooks.PSObject.Properties[$EventName]
        if ($prop) {
            foreach ($h in @($prop.Value)) {
                $c = [string]$h.command
                if ($c -match "cursor-neko-maid") { continue }
                $kept += $h
            }
        }
        $kept += [pscustomobject]@{ command = $cmd }
        $obj.hooks | Add-Member -NotePropertyName $EventName -NotePropertyValue @($kept) -Force
    }

    Set-NekoHook "sessionStart" "session-start"
    Set-NekoHook "beforeSubmitPrompt" "before-submit"

    $json = $obj | ConvertTo-Json -Depth 12
    [System.IO.File]::WriteAllText($HooksPath, $json + "`n", (New-Object System.Text.UTF8Encoding $false))
    Write-Host "已挂全局 hook -> $HooksPath"
    Write-Host "备份 -> $backup"
}

Write-Host ""
Write-Host "1) 完全退出并重启 Cursor"
Write-Host "2) 新开一条对话（旧聊天不会补加载）"
Write-Host "3) 可选加强：把 USER_RULES.txt 贴进 Settings → Rules → User Rules"
