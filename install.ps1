# Восстановление сетапа: запусти в PowerShell 7 из папки dotfiles
#   .\install.ps1
# Нужен включённый режим разработчика (для ссылок).

$dot = $PSScriptRoot

# --- программы ---
$apps = @(
    'Git.Git', 'Microsoft.PowerShell', 'wez.wezterm', 'glzr-io.glazewm',
    'glzr-io.zebar', 'Microsoft.PowerToys', 'CharlesMilette.TranslucentTB',
    'Fastfetch-cli.Fastfetch', 'eza-community.eza', 'ajeetdsouza.zoxide',
    'junegunn.fzf', 'sharkdp.bat', 'aristocratos.btop4win', 'JesseDuffield.lazygit'
)
foreach ($a in $apps) {
    winget install --id $a -e --accept-source-agreements --accept-package-agreements
}
Install-Module PSFzf -Scope CurrentUser -Force

# --- ссылки на конфиги ---
$links = [ordered]@{
    $PROFILE                                 = 'powershell\Microsoft.PowerShell_profile.ps1'
    "$HOME\.wezterm.lua"                     = 'wezterm\.wezterm.lua'
    "$HOME\.glzr\glazewm\config.yaml"        = 'glazewm\config.yaml'
    "$HOME\.glzr\zebar\vanilla-clear"        = 'zebar\vanilla-clear'
    "$HOME\.config\fastfetch\config.jsonc"   = 'fastfetch\config.jsonc'
}
foreach ($k in $links.Keys) {
    $target = Join-Path $dot $links[$k]
    New-Item -ItemType Directory -Force (Split-Path $k) | Out-Null
    if (Test-Path $k) { Move-Item $k "$k.old" -Force }
    New-Item -ItemType SymbolicLink -Path $k -Target $target | Out-Null
    Write-Host "ok: $k"
}

Write-Host ''
Write-Host 'Готово. Осталось вручную:'
Write-Host '  1. собрать шрифт Iosevka по fonts\private-build-plans.toml и установить'
Write-Host '  2. Set-ExecutionPolicy -Scope CurrentUser RemoteSigned (если ругается на скрипты)'
Write-Host '  3. запустить GlazeWM'
