$ErrorActionPreference = "Stop"
$CursorHome = Join-Path $env:USERPROFILE ".cursor"
$Dest = Join-Path $CursorHome "plugins\local\cursor-neko-maid"
$Rule = Join-Path $CursorHome "rules\master-nya.mdc"
$HooksPath = Join-Path $CursorHome "hooks.json"

if (Test-Path $Dest) {
    Remove-Item -Recurse -Force $Dest
    Write-Host "已删除 $Dest"
} else {
    Write-Host "未找到插件目录: $Dest"
}

if (Test-Path $Rule) {
    Remove-Item -Force $Rule
    Write-Host "已删除 $Rule"
}

if (Test-Path $HooksPath) {
    $obj = [System.IO.File]::ReadAllText($HooksPath) | ConvertFrom-Json
    if ($obj.hooks) {
        foreach ($p in @($obj.hooks.PSObject.Properties)) {
            $kept = @()
            foreach ($h in @($p.Value)) {
                $c = [string]$h.command
                if ($c -match "cursor-neko-maid") { continue }
                $kept += $h
            }
            if ($kept.Count -gt 0) {
                $obj.hooks | Add-Member -NotePropertyName $p.Name -NotePropertyValue @($kept) -Force
            } else {
                $obj.hooks.PSObject.Properties.Remove($p.Name)
            }
        }
        $json = $obj | ConvertTo-Json -Depth 12
        [System.IO.File]::WriteAllText($HooksPath, $json + "`n", (New-Object System.Text.UTF8Encoding $false))
        Write-Host "已从 hooks.json 移除猫娘条目"
    }
}

Write-Host "请重启 Cursor"
