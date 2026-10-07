# Восстановление сетапа dzubokko/win11-config
# Запуск в PowerShell 7 из папки репозитория:  .\install.ps1
# Перед запуском включи режим разработчика:
#   Параметры → Система → Для разработчиков → Режим разработчика

$dot = $PSScriptRoot

Write-Host "`n== Программы ==" -ForegroundColor Cyan
$apps = @(
    'Git.Git', 'Microsoft.PowerShell', 'wez.wezterm', 'glzr-io.glazewm', 'AmN.yasb',
    'Microsoft.PowerToys', 'CharlesMilette.TranslucentTB', 'DEVCOM.JetBrainsMonoNerdFont',
    'Fastfetch-cli.Fastfetch', 'eza-community.eza', 'ajeetdsouza.zoxide', 'junegunn.fzf',
    'sharkdp.bat', 'aristocratos.btop4win', 'JesseDuffield.lazygit'
)
foreach ($a in $apps) {
    winget install --id $a -e --accept-source-agreements --accept-package-agreements
}
Install-Module PSFzf -Scope CurrentUser -Force

# подхватить новые программы без перезапуска терминала
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [Environment]::GetEnvironmentVariable('Path', 'User')

Write-Host "`n== Ссылки на конфиги ==" -ForegroundColor Cyan
$links = [ordered]@{
    $PROFILE                               = 'powershell\Microsoft.PowerShell_profile.ps1'
    "$HOME\.wezterm.lua"                   = 'wezterm\.wezterm.lua'
    "$HOME\.glzr\glazewm\config.yaml"      = 'glazewm\config.yaml'
    "$HOME\.config\fastfetch\config.jsonc" = 'fastfetch\config.jsonc'
    "$HOME\.config\yasb"                   = 'yasb'
}
foreach ($k in $links.Keys) {
    $target = Join-Path $dot $links[$k]
    if (-not (Test-Path $target)) { Write-Host "нет в репозитории: $target" -ForegroundColor Yellow; continue }
    New-Item -ItemType Directory -Force (Split-Path $k) | Out-Null
    if (Test-Path $k) { Move-Item $k "$k.old" -Force }
    New-Item -ItemType SymbolicLink -Path $k -Target $target | Out-Null
    Write-Host "ok: $k"
}

Write-Host "`n== Темы bat (Catppuccin) ==" -ForegroundColor Cyan
$themes = Join-Path (bat --config-dir) 'themes'
New-Item -ItemType Directory -Force $themes | Out-Null
foreach ($t in 'Mocha', 'Latte') {
    Invoke-WebRequest "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20$t.tmTheme" -OutFile "$themes\Catppuccin $t.tmTheme"
}
bat cache --build

Write-Host "`n== Прозрачный проводник (ExplorerBlurMica) ==" -ForegroundColor Cyan
if ((Read-Host 'Установить? (y/n)') -eq 'y') {
    $dir = 'C:\Tools\ExplorerBlurMica'
    New-Item -ItemType Directory -Force $dir | Out-Null
    $rel = Invoke-RestMethod 'https://api.github.com/repos/Maplespe/ExplorerBlurMica/releases/latest'
    $asset = $rel.assets | Where-Object name -like '*.zip' | Select-Object -First 1
    $zip = "$env:TEMP\$($asset.name)"
    Invoke-WebRequest $asset.browser_download_url -OutFile $zip
    Expand-Archive $zip $dir -Force
    $ini = Get-ChildItem $dir -Recurse -Filter config.ini | Select-Object -First 1
    if ($ini -and (Test-Path "$dot\explorerblurmica\config.ini")) {
        Remove-Item $ini.FullName -Force
        New-Item -ItemType SymbolicLink -Path $ini.FullName -Target "$dot\explorerblurmica\config.ini" | Out-Null
    }
    $reg = Get-ChildItem $dir -Recurse -Filter register.cmd | Select-Object -First 1
    Start-Process cmd -ArgumentList "/c `"$($reg.FullName)`"" -WorkingDirectory $reg.DirectoryName -Verb RunAs
}

Write-Host "`n== Готово. Осталось вручную ==" -ForegroundColor Green
Write-Host '  1. Шрифт Iosevka Custom: собрать по fonts\private-build-plans.toml и установить'
Write-Host '  2. Ключ погоды: сохранить в ~\.config\yasb\.env строку YASB_WEATHER_API_KEY=...'
Write-Host '  3. Обои: положить картинки в ~\Pictures\Wallpapers'
Write-Host '  4. Запустить GlazeWM, затем: yasbc start; yasbc enable-autostart'
Write-Host '  5. Windhawk: моды Taskbar Styler, Taskbar height and icon size, Taskbar Clock Customization, Taskbar Labels; настройки через whcopy (см. README)'
Write-Host '  6. Если ругается на скрипты: Set-ExecutionPolicy -Scope CurrentUser RemoteSigned'

