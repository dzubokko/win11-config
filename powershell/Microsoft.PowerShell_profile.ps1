# =====================================================================
#  Профиль PowerShell (dzubokko)
# =====================================================================


# --- Предсказания при вводе -------------------------------------------
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineOption -Colors @{
    Command          = "`e[38;2;137;180;250m"
    Parameter        = "`e[38;2;249;226;175m"
    String           = "`e[38;2;166;227;161m"
    Operator         = "`e[38;2;137;220;235m"
    Variable         = "`e[38;2;245;194;231m"
    Number           = "`e[38;2;250;179;135m"
    Type             = "`e[38;2;249;226;175m"
    Keyword          = "`e[38;2;203;166;247m"
    Member           = "`e[38;2;180;190;254m"
    Comment          = "`e[38;2;108;112;134m"
    Error            = "`e[38;2;243;139;168m"
    InlinePrediction = "`e[38;2;88;91;112m"
    ListPrediction   = "`e[38;2;137;180;250m"
    Selection        = "`e[48;2;69;71;90m"
}

# Единая тема для всех окон fzf
$env:FZF_DEFAULT_OPTS = '--color=bg+:#313244,bg:-1,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#7f849c,info:#cba6f7,pointer:#f5e0dc,marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8,border:#45475a --border=rounded --layout=reverse'

# Тема bat
$env:BAT_THEME = 'Catppuccin Mocha'

# Tab показывает меню вариантов, как в Linux
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Стрелки вверх/вниз ищут по истории с учётом уже набранного
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward


# --- Приглашение ------------------------------------------------------
function prompt {
    $ok = $?
    $e = [char]27
    $frame = "$e[38;2;88;91;112m";  $user  = "$e[38;2;180;190;254m"
    $pathc = "$e[38;2;137;180;250m"; $gitc  = "$e[38;2;166;227;161m"
    $dirty = "$e[38;2;249;226;175m"; $timec = "$e[38;2;127;132;156m"
    $good  = "$e[38;2;203;166;247m"; $bad   = "$e[38;2;243;139;168m"
    $r     = "$e[0m"

    $path = $PWD.Path.Replace($HOME, '~')

    # git-ветка и признак незакоммиченных изменений
    $git = ''
    $branch = git branch --show-current 2>$null
    if ($branch) {
        $mark = if (git status --porcelain 2>$null) { " $dirty●" } else { '' }
        $git = "  $gitc$([char]0xE0A0) $branch$mark"
    }

    # время выполнения прошлой команды, если дольше 2 секунд
    $dur = ''
    $last = Get-History -Count 1
    if ($last) {
        $s = ($last.EndExecutionTime - $last.StartExecutionTime).TotalSeconds
        if ($s -ge 2) { $dur = "  $timec$([char]0xF017) $([math]::Round($s, 1))s" }
    }

    $lam = if ($ok) { $good } else { $bad }
    "$frame$([char]0x250C)[$user$env:USERNAME$frame] $pathc$path$git$dur$r`n$frame$([char]0x2514) $lam$([char]0x03BB)$r "
}


# --- Утилиты (подключаются, только если установлены) ------------------

# zoxide: умный cd (z <слово>, zi)
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# eza: минималистичный ls
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    $env:EZA_COLORS = "di=38;2;137;180;250:fi=38;2;205;214;244:da=38;2;108;112;134:sn=38;2;150;150;160:sb=38;2;108;112;134"
    $global:ezaBase = @('--group-directories-first', '--classify', '--no-quotes')
    function ls { eza @ezaBase @args }
    function ll { eza -l --no-permissions --no-user --git @ezaBase @args }
    function la { eza -la --no-permissions --no-user @ezaBase @args }
    function lt { eza --tree --level=2 @ezaBase @args }
}
# fzf: Ctrl+R поиск по истории, Ctrl+T вставить путь к файлу
if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Import-Module PSFzf -PassThru -ErrorAction SilentlyContinue)) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# fastfetch при запуске терминала (удали этот блок, если надоест)
$ffConfig = "$HOME\.config\fastfetch\config.jsonc"
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    if (Test-Path $ffConfig) { fastfetch --config $ffConfig } else { fastfetch }
}


# --- Заметки и задачи ----------------------------------------------------
$global:NotesDir = "$HOME\notes"
$global:NotesFzfColors = 'fg:#a6adc8,fg+:#cdd6f4,bg+:#313244,hl:#89b4fa,hl+:#89b4fa,prompt:#89b4fa,pointer:#89b4fa,border:#45475a,header:#7f849c,info:#7f849c,label:#89b4fa,query:#cdd6f4'

function Initialize-Notes {
    New-Item -ItemType Directory -Force "$NotesDir\journal", "$NotesDir\notes" | Out-Null
    if (-not (Test-Path "$NotesDir\inbox.md")) { Set-Content "$NotesDir\inbox.md" "# Входящие`n" -Encoding utf8 }
    if (-not (Test-Path "$NotesDir\tasks.md")) { Set-Content "$NotesDir\tasks.md" "# Задачи`n" -Encoding utf8 }
}

function Open-Note([string]$Path, [int]$Line = 0) {
    if (Get-Command nvim -ErrorAction SilentlyContinue) {
        if ($Line) { nvim "+$Line" $Path } else { nvim $Path }
    } elseif (Get-Command code -ErrorAction SilentlyContinue) {
        if ($Line) { code -g "${Path}:$Line" } else { code $Path }
    } else {
        notepad $Path
    }
}

function Write-NoteMsg([string]$Mark, [string]$Text) {
    $e = [char]27
    Write-Host "  $e[38;2;137;180;250m$Mark$e[0m $e[38;2;205;214;244m$Text$e[0m"
}

# i <мысль> — во входящие; i — показать входящие
function i {
    Initialize-Notes
    $f = "$NotesDir\inbox.md"
    $text = $args -join ' '
    if (-not $text) {
        if (Get-Command bat -ErrorAction SilentlyContinue) { bat --style=plain --paging=never $f } else { Get-Content $f }
        return
    }
    Add-Content $f "- $(Get-Date -Format 'dd.MM HH:mm')  $text" -Encoding utf8
    Write-NoteMsg '+' $text
}

# t <задача> — добавить; t — список открытых
function t {
    Initialize-Notes
    $f = "$NotesDir\tasks.md"
    $text = $args -join ' '
    if ($text) {
        Add-Content $f "- [ ] $text" -Encoding utf8
        Write-NoteMsg '+' $text
        return
    }
    $e = [char]27
    $num = 0
    Write-Host ''
    foreach ($l in Get-Content $f) {
        if ($l -match '^\s*- \[ \] (.+)$') {
            $num++
            Write-Host ("  $e[38;2;108;112;134m{0,2}$e[0m  $e[38;2;137;180;250m○$e[0m  {1}" -f $num, $matches[1])
        }
    }
    if ($num -eq 0) { Write-NoteMsg '✓' 'открытых задач нет' }
    Write-Host ''
}

# td — отметить выполненные (fzf); td 1 3 — по номерам
function td {
    Initialize-Notes
    $f = "$NotesDir\tasks.md"
    $lines = [System.Collections.Generic.List[string]]::new([string[]](Get-Content $f))
    $open = [System.Collections.Generic.List[int]]::new()
    for ($k = 0; $k -lt $lines.Count; $k++) { if ($lines[$k] -match '^\s*- \[ \] ') { $open.Add($k) } }
    if ($open.Count -eq 0) { Write-NoteMsg '✓' 'открытых задач нет'; return }

    $nums = @($args | ForEach-Object { [int]$_ })
    if ($nums.Count -eq 0) {
        $items = for ($j = 0; $j -lt $open.Count; $j++) { "$($j + 1)`t" + ($lines[$open[$j]] -replace '^\s*- \[ \] ', '') }
        $sel = @($items | fzf -m '--delimiter=\t' --with-nth=2 --layout=reverse --border=rounded '--border-label= выполнено ' '--prompt=› ' '--pointer=▌' '--header=Tab отметить несколько · Enter готово · Esc отмена' "--color=$NotesFzfColors")
        $nums = @($sel | ForEach-Object { [int]($_ -split "`t")[0] })
    }
    foreach ($x in $nums) {
        if ($x -lt 1 -or $x -gt $open.Count) { continue }
        $k = $open[$x - 1]
        $lines[$k] = ($lines[$k] -replace '- \[ \] ', '- [x] ') + "  ✓ $(Get-Date -Format 'dd.MM')"
        Write-NoteMsg '✓' ($lines[$k] -replace '^\s*- \[x\] ', '')
    }
    Set-Content $f $lines -Encoding utf8
}

# tclean — перенести выполненные в архив
function tclean {
    Initialize-Notes
    $f = "$NotesDir\tasks.md"
    $lines = @(Get-Content $f)
    $done = @($lines | Where-Object { $_ -match '^\s*- \[x\] ' })
    if ($done.Count -eq 0) { Write-NoteMsg '·' 'выполненных задач нет'; return }
    Add-Content "$NotesDir\tasks-done.md" $done -Encoding utf8
    Set-Content $f @($lines | Where-Object { $_ -notmatch '^\s*- \[x\] ' }) -Encoding utf8
    Write-NoteMsg '→' "в архив: $($done.Count)"
}

# j — дневник на сегодня
function j {
    Initialize-Notes
    $d = Get-Date
    $f = "$NotesDir\journal\$($d.ToString('yyyy-MM-dd')).md"
    if (-not (Test-Path $f)) {
        $title = $d.ToString('dddd, d MMMM yyyy', [Globalization.CultureInfo]'ru-RU')
        Set-Content $f "# $title`n`n## Планы`n`n- `n`n## Заметки`n`n" -Encoding utf8
    }
    Open-Note $f
}

# n — выбрать заметку в fzf (новое имя + Enter = создать); n <имя> — открыть или создать
function n {
    Initialize-Notes
    $name = $args -join ' '
    if ($name) {
        $f = Join-Path $NotesDir "notes\$name.md"
        if (-not (Test-Path $f)) { Set-Content $f "# $name`n`n" -Encoding utf8 }
        Open-Note $f
        return
    }
    Push-Location $NotesDir
    try {
        $files = Get-ChildItem -Recurse -Filter *.md -File |
            Sort-Object LastWriteTime -Descending |
            ForEach-Object { [IO.Path]::GetRelativePath($NotesDir, $_.FullName) }
        $out = @($files | fzf --print-query --layout=reverse --border=rounded '--border-label= заметки ' '--prompt=› ' '--pointer=▌' '--header=Enter открыть · новое имя + Enter создать · Esc выход' '--preview=bat --color=always --style=plain {}' "--color=$NotesFzfColors")
        $code = $LASTEXITCODE
    } finally { Pop-Location }
    if ($code -eq 130 -or $out.Count -eq 0) { return }
    $query = $out[0]
    $pick = if ($out.Count -ge 2) { $out[1] } else { '' }
    if ($pick) { Open-Note (Join-Path $NotesDir $pick) }
    elseif ($query) { n $query }
}

# ns <текст> — поиск по всем заметкам
function ns {
    Initialize-Notes
    $q = $args -join ' '
    if (-not $q) { Write-NoteMsg '?' 'ns <что искать>'; return }
    Push-Location $NotesDir
    try {
        $hits = @(Get-ChildItem -Recurse -Filter *.md -File |
            Select-String -SimpleMatch -Pattern $q |
            ForEach-Object { '{0}:{1}:{2}' -f [IO.Path]::GetRelativePath($NotesDir, $_.Path), $_.LineNumber, $_.Line.Trim() })
        if ($hits.Count -eq 0) { Write-NoteMsg '·' "ничего не найдено: $q"; return }
        $sel = $hits | fzf '--delimiter=:' --layout=reverse --border=rounded '--border-label= поиск ' '--prompt=› ' '--pointer=▌' '--preview=bat --color=always --style=numbers --highlight-line {2} {1}' '--preview-window=+{2}-5' "--color=$NotesFzfColors"
    } finally { Pop-Location }
    if ($sel) {
        $parts = $sel -split ':'
        Open-Note (Join-Path $NotesDir $parts[0]) ([int]$parts[1])
    }
}

# nsync — сохранить заметки в git и отправить
function nsync {
    Initialize-Notes
    Push-Location $NotesDir
    try {
        if (-not (Test-Path .git)) { git init -q -b main }
        git add -A
        git commit -q -m "notes $(Get-Date -Format 'yyyy-MM-dd HH:mm')" | Out-Null
        if (git remote) { git push -q -u origin HEAD; Write-NoteMsg '✓' 'заметки сохранены и отправлены' }
        else { Write-NoteMsg '✓' 'сохранено локально (нет remote для отправки)' }
    } finally { Pop-Location }
}
# --- Кодировка для внешних программ (fzf и др.) -----------------------
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# --- Шпаргалка ---------------------------------------------------------
#   cheat            интерактивная шпаргалка
#   cheat <раздел>   один раздел (Tab подскажет названия)
#   cheat <слово>    сразу с поиском
#   cheat -Print     обычный текстовый вывод
#   F1               шпаргалка со вставкой команды в строку ввода

function Get-CheatData {
    [ordered]@{
        wm = @{ Title = 'GlazeWM: окна'; Items = @(
            @('Alt+Enter',              'открыть терминал (WezTerm)', ''),
            @('Alt+E',                  'открыть проводник', ''),
            @('Alt+B',                  'открыть Chrome (уедет на стол 2)', ''),
            @('Alt+Shift+Q',            'закрыть окно', ''),
            @('Alt+H/J/K/L',            'фокус влево/вниз/вверх/вправо', ''),
            @('Alt+стрелки',            'фокус стрелками', ''),
            @('Alt+Shift+H/J/K/L',      'переместить окно', ''),
            @('Alt+Shift+стрелки',      'переместить окно стрелками', ''),
            @('Alt+V',                  'сменить направление разбиения', ''),
            @('Alt+F',                  'полный экран вкл/выкл', ''),
            @('Alt+Shift+Space',        'плавающее окно', ''),
            @('Alt+T',                  'вернуть окно в плитку', ''),
            @('Alt+M',                  'свернуть окно', ''),
            @('Alt+U / Alt+P',          'уже / шире на 2%', ''),
            @('Alt+I / Alt+O',          'ниже / выше на 2%', ''),
            @('Alt+R',                  'режим ресайза', ''),
            @('ресайз: H/J/K/L',        'менять размер (или стрелками)', ''),
            @('ресайз: Esc / Enter',    'выйти из режима ресайза', ''),
            @('Alt+Shift+P',            'пауза всех хоткеев вкл/выкл', ''),
            @('Alt+Shift+R',            'перечитать конфиг', ''),
            @('Alt+Shift+W',            'перерисовать все окна', ''),
            @('Alt+Shift+E',            'выйти из GlazeWM', '')
        )}
        ws = @{ Title = 'GlazeWM: рабочие столы'; Items = @(
            @('Alt+1..9',               'перейти на стол', ''),
            @('Alt+Shift+1..9',         'перенести окно на стол и перейти', ''),
            @('Alt+S',                  'следующий стол', ''),
            @('Alt+A',                  'предыдущий стол', ''),
            @('Alt+D',                  'последний открытый стол', ''),
            @('Alt+Shift+A / F',        'стол на монитор слева / справа', ''),
            @('Alt+Shift+D / S',        'стол на монитор сверху / снизу', ''),
            @('клик в Zebar',           'переключить стол мышью', '')
        )}
        term = @{ Title = 'WezTerm'; Items = @(
            @('Ctrl+Shift+Alt+H',       'разделить: панель справа', ''),
            @('Ctrl+Shift+Alt+V',       'разделить: панель снизу', ''),
            @('Ctrl+Shift+стрелки',     'перейти в соседнюю панель', ''),
            @('Ctrl+9',                 'выбрать панель по букве', ''),
            @('Ctrl+Shift+U/I/O/P',     'размер панели', ''),
            @('Ctrl+Shift+Z',           'развернуть панель / вернуть', ''),
            @('exit',                   'закрыть текущую панель', ''),
            @('Ctrl+Shift+T',           'новая вкладка', ''),
            @('Ctrl+Shift+N',           'новое окно', ''),
            @('Ctrl+Tab / Ctrl+Shift+Tab', 'следующая / предыдущая вкладка', ''),
            @('Ctrl+Shift+1..9',        'перейти на вкладку по номеру', ''),
            @('Ctrl+Shift+W',           'закрыть вкладку', ''),
            @('Ctrl+Shift+C / V',       'копировать / вставить', ''),
            @('Ctrl+Shift+F',           'поиск по выводу', ''),
            @('Ctrl+Shift+X',           'режим копирования с клавиатуры', ''),
            @('Ctrl+Shift+Space',       'быстрый выбор (пути, хэши, URL)', ''),
            @('Ctrl+Shift+K',           'очистить историю прокрутки', ''),
            @('Shift+PageUp / PageDown', 'прокрутка вывода', ''),
            @('Ctrl+= / Ctrl+-',        'крупнее / мельче', ''),
            @('Ctrl+0',                 'сбросить размер шрифта', ''),
            @('Ctrl+Alt+O',             'прозрачность вкл/выкл', ''),
            @('Ctrl+Shift+Alt+E',       'сменить цветовую схему', '')
        )}
        ps = @{ Title = 'PowerShell: ввод'; Items = @(
            @('F1',                     'шпаргалка со вставкой команды', ''),
            @('Right / End',            'принять подсказку целиком', ''),
            @('Ctrl+Right',             'принять одно слово подсказки', ''),
            @('Esc',                    'очистить строку / убрать подсказку', ''),
            @('F2',                     'подсказки строкой / списком', ''),
            @('Tab',                    'меню автодополнения', ''),
            @('Up / Down',              'история по набранному', ''),
            @('Ctrl+R',                 'поиск по всей истории (fzf)', ''),
            @('Ctrl+T',                 'вставить путь к файлу (fzf)', ''),
            @('Home / End',             'в начало / конец строки', ''),
            @('Ctrl+Left / Right',      'по словам', ''),
            @('Ctrl+Backspace',         'удалить слово слева', ''),
            @('Ctrl+Z',                 'отменить правку строки', ''),
            @('Ctrl+L',                 'очистить экран', ''),
            @('Ctrl+C',                 'прервать команду', '')
        )}
        shell = @{ Title = 'PowerShell: основы'; Items = @(
            @('cd <папка>',             'перейти в папку', 'cd '),
            @('cd ..',                  'на уровень выше', 'cd ..'),
            @('cd ~',                   'домой', 'cd ~'),
            @('pwd',                    'где я сейчас', 'pwd'),
            @('cls',                    'очистить экран', 'cls'),
            @('λ красная',              'прошлая команда завершилась ошибкой', ''),
            @('● после ветки',          'есть незакоммиченные изменения', ''),
            @('часы в приглашении',     'сколько шла прошлая команда (от 2 сек)', ''),
            @('история',                'последние 20 команд', 'Get-History | Select-Object -Last 20'),
            @('explorer .',             'открыть папку в проводнике', 'explorer .'),
            @('code .',                 'открыть папку в VS Code', 'code .'),
            @('ii <файл>',              'открыть файл программой по умолчанию', 'ii '),
            @('Get-Help <команда>',     'справка по команде', 'Get-Help '),
            @('gcm <слово>',            'найти команду по имени', 'gcm '),
            @('путь к профилю',         'где лежит этот профиль', 'echo $PROFILE'),
            @('<команда> | clip',       'скопировать вывод в буфер', '| clip')
        )}
        file = @{ Title = 'Файлы и папки'; Items = @(
            @('mkdir <имя>',            'создать папку', 'mkdir '),
            @('ni <файл>',              'создать пустой файл', 'ni '),
            @('cp <откуда> <куда>',     'копировать файл', 'cp '),
            @('cp -r <откуда> <куда>',  'копировать папку', 'cp -r '),
            @('mv <откуда> <куда>',     'переместить', 'mv '),
            @('ren <старое> <новое>',   'переименовать', 'ren '),
            @('rm <файл>',              'удалить файл', 'rm '),
            @('rm -r <папка>',          'удалить папку целиком', 'rm -r '),
            @('найти по маске',         'например *.txt во всех подпапках', 'Get-ChildItem -Recurse -Filter '),
            @('размер папки',           'вес текущей папки в МБ', '"{0:N1} MB" -f ((Get-ChildItem -Recurse -File | Measure-Object Length -Sum).Sum / 1MB)'),
            @('zip: упаковать',         'Compress-Archive -Path что -DestinationPath x.zip', 'Compress-Archive -Path '),
            @('zip: распаковать',       'Expand-Archive x.zip', 'Expand-Archive ')
        )}
        ls = @{ Title = 'Список файлов (eza)'; Items = @(
            @('ls',                     'файлы и папки', 'ls'),
            @('ls -1',                  'по одному в строке', 'ls -1'),
            @('ls -D',                  'только папки', 'ls -D'),
            @('ls -f',                  'только файлы', 'ls -f'),
            @('ls -a',                  'со скрытыми, коротко', 'ls -a'),
            @('ls <папка>',             'содержимое другой папки', 'ls '),
            @('ls *.ps1',               'только по расширению', 'ls *.'),
            @('ll',                     'подробно: размер, дата, git', 'll'),
            @('ll -s name',             'по имени', 'll -s name'),
            @('ll -s size -r',          'крупные файлы сверху', 'll -s size -r'),
            @('ll -s modified -r',      'свежие файлы сверху', 'll -s modified -r'),
            @('la',                     'подробно со скрытыми', 'la'),
            @('la -s modified -r',      'со скрытыми, свежие сверху', 'la -s modified -r'),
            @('lt',                     'дерево на 2 уровня', 'lt'),
            @('lt -L 3',                'дерево на 3 уровня', 'lt -L 3'),
            @('lt -D',                  'дерево только из папок', 'lt -D'),
            @('lt <папка>',             'дерево другой папки', 'lt ')
        )}
        nav = @{ Title = 'Переходы (zoxide)'; Items = @(
            @('z <слово>',              'прыгнуть в папку по кусочку имени', 'z '),
            @('z <слово> <слово>',      'уточнить несколькими словами', 'z '),
            @('zi',                     'выбрать папку из списка', 'zi'),
            @('zi <слово>',             'список только подходящих', 'zi '),
            @('z -',                    'назад в предыдущую папку', 'z -'),
            @('z ..',                   'на уровень выше', 'z ..'),
            @('z ~',                    'домой', 'z ~'),
            @('zoxide query -l',        'все запомненные папки', 'zoxide query -l'),
            @('zoxide query <слово>',   'показать путь, не переходя', 'zoxide query '),
            @('zoxide remove <путь>',   'забыть папку', 'zoxide remove ')
        )}
        find = @{ Title = 'Поиск (fzf)'; Items = @(
            @('Ctrl+R',                 'поиск по истории команд', ''),
            @('Ctrl+T',                 'найти файл и вставить путь', ''),
            @('fzf',                    'найти файл', 'fzf'),
            @('fzf -m',                 'выбрать несколько (Tab отмечает)', 'fzf -m'),
            @('fzf + предпросмотр',     'поиск с превью справа', 'fzf --preview "bat --color=always {}"'),
            @('nvim (fzf)',             'найти и открыть в Neovim', 'nvim (fzf)'),
            @('bat (fzf)',              'найти и посмотреть', 'bat (fzf)'),
            @('code (fzf)',             'найти и открыть в VS Code', 'code (fzf)'),
            @('winget list | fzf',      'поиск по программам', 'winget list | fzf'),
            @('процессы | fzf',         'поиск по процессам', 'Get-Process | Out-String -Stream | fzf'),
            @('fzf: стрелки / Ctrl+J/K', 'двигаться по списку', ''),
            @('fzf: Enter / Esc',       'выбрать / отмена', ''),
            @('fzf: слово1 слово2',     'оба слова в любом порядке', ''),
            @("fzf: 'слово",            'точное совпадение', ''),
            @('fzf: ^начало',           'строка начинается с', ''),
            @('fzf: конец$',            'строка заканчивается на', ''),
            @('fzf: !слово',            'исключить слово', '')
        )}
        view = @{ Title = 'Просмотр (bat)'; Items = @(
            @('bat <файл>',             'файл с подсветкой', 'bat '),
            @('bat $PROFILE',           'посмотреть этот профиль', 'bat $PROFILE'),
            @('bat -p <файл>',          'без рамки и номеров', 'bat -p '),
            @('bat -n <файл>',          'только номера строк', 'bat -n '),
            @('bat -r 10:30 <файл>',    'только строки 10-30', 'bat -r 10:30 '),
            @('bat -A <файл>',          'показать пробелы и табы', 'bat -A '),
            @('bat -l json <файл>',     'указать язык подсветки', 'bat -l '),
            @('bat --list-themes',      'все темы оформления', 'bat --list-themes'),
            @('bat: пробел / b',        'страница вниз / вверх', ''),
            @('bat: /текст, n',         'поиск, следующее совпадение', ''),
            @('bat: g / G',             'начало / конец файла', ''),
            @('bat: q',                 'выход', '')
        )}
        git = @{ Title = 'git'; Items = @(
            @('git status',             'что изменено', 'git status'),
            @('git diff',               'изменения построчно', 'git diff'),
            @('git log --oneline',      'последние 20 коммитов', 'git log --oneline -n 20'),
            @('git log --graph',        'дерево веток', 'git log --oneline --graph --all -n 30'),
            @('git branch',             'список веток', 'git branch'),
            @('git add .',              'добавить все изменения', 'git add . '),
            @('git commit -m',          'сделать коммит', 'git commit -m '),
            @('git push',               'отправить на сервер', 'git push '),
            @('git pull',               'забрать с сервера', 'git pull '),
            @('git switch <ветка>',     'перейти на ветку', 'git switch '),
            @('git switch -c <ветка>',  'создать ветку и перейти', 'git switch -c '),
            @('git stash / stash pop',  'отложить изменения / вернуть', 'git stash '),
            @('git restore <файл>',     'отменить изменения файла', 'git restore '),
            @('git clone <url>',        'скачать репозиторий', 'git clone ')
        )}
        lg = @{ Title = 'lazygit'; Items = @(
            @('lazygit',                'открыть (в папке репозитория)', 'lazygit'),
            @('1..5 / Left Right',      'переключение панелей', ''),
            @('j/k / стрелки',          'движение по списку', ''),
            @('Enter / Esc',            'открыть подробнее / назад', ''),
            @('файлы: Space',           'добавить/убрать файл из коммита', ''),
            @('файлы: a',               'добавить все файлы', ''),
            @('файлы: d',               'отменить изменения (осторожно)', ''),
            @('файлы: s',               'отложить в stash', ''),
            @('c',                      'написать коммит', ''),
            @('P / p',                  'push / pull', ''),
            @('ветки: Space',           'перейти на ветку', ''),
            @('ветки: n',               'новая ветка', ''),
            @('?',                      'все клавиши текущей панели', ''),
            @('q',                      'выход', '')
        )}
        sys = @{ Title = 'Система'; Items = @(
            @('btop',                   'диспетчер задач в терминале', 'btop'),
            @('btop: Left / Right',     'сменить сортировку (cpu, mem...)', ''),
            @('btop: f',                'фильтр по имени процесса', ''),
            @('btop: Enter',            'подробности процесса', ''),
            @('btop: k',                'завершить процесс', ''),
            @('btop: m / q',            'меню и темы / выход', ''),
            @('топ-10 по памяти',       'самые прожорливые процессы', 'Get-Process | Sort-Object WS -Descending | Select-Object -First 10 Name, Id, @{n="MB"; e={[int]($_.WS / 1MB)}}'),
            @('Stop-Process -Name',     'закрыть программу по имени', 'Stop-Process -Name '),
            @('fastfetch',              'информация о системе', 'fastfetch'),
            @('fastfetch (полный)',     'с большим логотипом', 'fastfetch --config none'),
            @('winget list',            'установленные программы', 'winget list'),
            @('winget upgrade',         'что можно обновить', 'winget upgrade'),
            @('winget upgrade --all',   'обновить все программы', 'winget upgrade --all '),
            @('winget search <имя>',    'найти программу', 'winget search '),
            @('winget install <id>',    'установить программу', 'winget install '),
            @('winget uninstall <id>',  'удалить программу', 'winget uninstall '),
            @('перезагрузка',           'перезагрузить компьютер', 'shutdown /r /t 0 ')
        )}
        net = @{ Title = 'Сеть'; Items = @(
            @('ipconfig',               'локальный IP и адаптеры', 'ipconfig'),
            @('внешний IP',             'твой адрес в интернете', 'Invoke-RestMethod ifconfig.me'),
            @('ping 8.8.8.8',           'есть ли интернет', 'ping 8.8.8.8 -n 4'),
            @('проверить сайт',         'доступен ли google.com:443', 'Test-NetConnection google.com -Port 443'),
            @('Test-NetConnection',     'проверить свой адрес и порт', 'Test-NetConnection -Port 443 '),
            @('сигнал Wi-Fi',           'сеть, скорость, уровень сигнала', 'netsh wlan show interfaces'),
            @('ipconfig /flushdns',     'сбросить кэш DNS', 'ipconfig /flushdns')
        )}
        nvim = @{ Title = 'Neovim (LazyVim)'; Items = @(
            @('nvim .',                 'открыть текущую папку', 'nvim .'),
            @('nvim <файл>',            'открыть файл', 'nvim '),
            @('i / a',                  'печатать перед / после курсора', ''),
            @('o / O',                  'новая строка ниже / выше', ''),
            @('Esc',                    'вернуться в режим команд', ''),
            @(':w / :q',                'сохранить / выйти', ''),
            @(':wq / :q!',              'сохранить и выйти / без сохранения', ''),
            @('h/j/k/l',                'влево/вниз/вверх/вправо', ''),
            @('w / b',                  'слово вперёд / назад', ''),
            @('0 / $',                  'начало / конец строки', ''),
            @('gg / G',                 'начало / конец файла', ''),
            @('Ctrl+D / Ctrl+U',        'полстраницы вниз / вверх', ''),
            @('x',                      'удалить символ', ''),
            @('dd / yy / p',            'удалить / копировать / вставить строку', ''),
            @('v / V',                  'выделение символов / строк', ''),
            @('ciw',                    'заменить слово под курсором', ''),
            @('>> / <<',                'сдвинуть строку вправо / влево', ''),
            @('u / Ctrl+R',             'отменить / повторить', ''),
            @('/текст, n / N',          'поиск, следующее / предыдущее', ''),
            @(':%s/было/стало/g',       'заменить во всём файле', ''),
            @('Space',                  'меню всех команд LazyVim', ''),
            @('Space Space',            'найти файл в проекте', ''),
            @('Space e',                'дерево файлов', ''),
            @('Space s g',              'поиск текста в проекте', ''),
            @('Shift+H / Shift+L',      'предыдущий / следующий файл', ''),
            @('Space b d',              'закрыть текущий файл', ''),
            @('gd / K',                 'к определению / документация', ''),
            @('Space c f',              'отформатировать файл', ''),
            @('Ctrl+/',                 'терминал внутри редактора', ''),
            @(':Lazy / :Mason',         'плагины / языковые серверы', ''),
            @(':Tutor',                 'встроенный урок', '')
        )}
        cfg = @{ Title = 'Конфиги'; Items = @(
            @('профиль',                'этот профиль PowerShell', 'notepad $PROFILE'),
            @('папка профиля',          'открыть в проводнике', 'explorer (Split-Path $PROFILE)'),
            @('WezTerm',                'конфиг терминала', 'notepad $HOME\.wezterm.lua'),
            @('GlazeWM',                'конфиг оконного менеджера', 'notepad $HOME\.glzr\glazewm\config.yaml'),
            @('Zebar',                  'папка виджетов бара', 'explorer $HOME\.glzr\zebar'),
            @('fastfetch',              'конфиг fastfetch', 'notepad $HOME\.config\fastfetch\config.jsonc'),
            @('Neovim',                 'папка конфига LazyVim', 'nvim $env:LOCALAPPDATA\nvim'),
            @('Alt+Shift+R',            'применить конфиг GlazeWM', ''),
            @('Ctrl+Shift+T',           'новая вкладка = применить профиль', '')
        )}
        notes = @{ Title = 'Заметки и задачи'; Items = @(
            @('i <мысль>',              'быстро записать во входящие', 'i '),
            @('i',                      'показать входящие', 'i'),
            @('t <задача>',             'добавить задачу', 't '),
            @('t',                      'список открытых задач', 't'),
            @('td',                     'отметить выполненные (Tab = несколько)', 'td'),
            @('td <номер>',             'отметить задачу по номеру', 'td '),
            @('tclean',                 'убрать выполненные в архив', 'tclean'),
            @('j',                      'дневник на сегодня', 'j'),
            @('n',                      'найти или создать заметку', 'n'),
            @('n <имя>',                'открыть или создать заметку', 'n '),
            @('ns <текст>',             'поиск по тексту всех заметок', 'ns '),
            @('nsync',                  'сохранить заметки в git', 'nsync'),
            @('папка заметок',          'открыть в проводнике', 'explorer $HOME\notes')
        )}
        win = @{ Title = 'Windows'; Items = @(
            @('Win+Space',              'сменить раскладку', ''),
            @('Win+V',                  'история буфера обмена', ''),
            @('Win+Shift+S',            'скриншот области', ''),
            @('Win+PrtScn',             'скриншот экрана в файл', ''),
            @('Win+.',                  'эмодзи и спецсимволы', ''),
            @('Win+E',                  'проводник', ''),
            @('Win+I',                  'параметры', ''),
            @('Win+X',                  'меню быстрых ссылок', ''),
            @('Win+D',                  'показать рабочий стол', ''),
            @('Win+Tab',                'все окна', ''),
            @('Alt+Tab',                'переключить окно', ''),
            @('Win+Shift+Left / Right', 'окно на другой монитор', ''),
            @('Win+G',                  'игровая панель, запись экрана', ''),
            @('Win+L',                  'заблокировать', ''),
            @('Ctrl+Shift+Esc',         'диспетчер задач', '')
        )}
        ptrun = @{ Title = 'PowerToys Run (Alt+Space)'; Items = @(
            @('текст',                  'найти программу или файл', ''),
            @('= 2*15',                 'калькулятор', ''),
            @('> ipconfig',             'выполнить команду', ''),
            @('< окно',                 'переключиться на окно', ''),
            @('// site.com',            'открыть сайт', ''),
            @('?? запрос',              'поиск в интернете', ''),
            @('$ дисплей',              'найти настройку Windows', ''),
            @('%% 10 km in mi',         'перевод единиц', ''),
            @('!! ',                    'история запусков', ''),
            @('?',                      'все возможности', '')
        )}
        pt = @{ Title = 'PowerToys: модули'; Items = @(
            @('Win+Shift+T',            'скопировать текст с экрана', ''),
            @('Win+Shift+C',            'взять цвет с экрана', ''),
            @('Win+Shift+V',            'умная вставка (Advanced Paste)', ''),
            @('Win+Shift+M',            'линейка на экране', ''),
            @('Win+Ctrl+T',             'окно поверх всех вкл/выкл', ''),
            @('Ctrl дважды',            'найти курсор мыши', ''),
            @('Ctrl+Space',             'предпросмотр файла (Peek)', ''),
            @('Win+Alt+Space',          'Command Palette', ''),
            @('Caps Lock',              'Esc (если настроил)', '')
        )}
    }
}
function cheat {
    param(
        [ArgumentCompleter({
            param($cmd, $param, $word)
            (Get-CheatData).Keys | Where-Object { $_ -like "$word*" }
        })]
        [string]$Query = '',
        [switch]$Print,
        [switch]$Pick
    )

    $e      = [char]27
    $accent = "$e[38;2;137;180;250m"
    $keyc   = "$e[38;2;205;214;244m"
    $dim    = "$e[38;2;127;132;156m"
    $secc   = "$e[38;2;108;112;134m"
    $runc   = "$e[38;2;166;227;161m"
    $r      = "$e[0m"
    $line   = [string][char]0x2500

    $data = Get-CheatData
    $q = $Query.Trim()
    $isSection = $q -and $data.Contains($q.ToLower())
    $sections = if ($isSection) { @($q.ToLower()) } else { @($data.Keys) }
    $search = if ($q -and -not $isSection) { $q } else { '' }

    $list = [System.Collections.Generic.List[object]]::new()
    foreach ($s in $sections) {
        foreach ($it in $data[$s].Items) {
            $list.Add([pscustomobject]@{ Sec = $s; Key = $it[0]; Desc = $it[1]; Run = $it[2] })
        }
    }

    # --- текстовый режим ---
    if ($Print -or -not (Get-Command fzf -ErrorAction SilentlyContinue)) {
        foreach ($s in $sections) {
            $items = @($list | Where-Object {
                $_.Sec -eq $s -and (-not $search -or $_.Key -like "*$search*" -or $_.Desc -like "*$search*")
            })
            if ($items.Count -eq 0) { continue }
            $title = $data[$s].Title
            $tail = $line * [Math]::Max(3, 44 - $title.Length)
            Write-Host ''
            Write-Host "  $accent$line$line $title $tail$r"
            foreach ($x in $items) {
                Write-Host "    $keyc$($x.Key.PadRight(24))$r$dim$($x.Desc)$r"
            }
        }
        Write-Host ''
        return
    }

    # --- интерактивный режим (fzf) ---
    $lines = for ($i = 0; $i -lt $list.Count; $i++) {
        $x = $list[$i]
        $mark = if (-not $x.Run) { ' ' } elseif ($x.Run.EndsWith(' ')) { "$accent›$r" } else { "$runc▸$r" }
        "$mark $secc$($x.Sec.PadRight(6))$r $keyc$($x.Key.PadRight(26))$r $dim$($x.Desc)$r`t$i"
    }

    $header = if ($Pick) {
        'Enter вставить в строку  ·  Esc выход'
    } else {
        'Enter выполнить  ·  Ctrl+Y копировать  ·  Esc выход      ▸ команда   › шаблон'
    }
    $colors = 'fg:#a6adc8,fg+:#cdd6f4,bg+:#313244,hl:#89b4fa,hl+:#89b4fa,prompt:#89b4fa,pointer:#89b4fa,border:#45475a,header:#7f849c,info:#7f849c,label:#89b4fa,query:#cdd6f4'

    $fzfArgs = @(
        '--ansi', '--layout=reverse', '--border=rounded',
        '--border-label= cheat ', '--prompt=› ', '--pointer=▌',
        '--info=inline-right', '--delimiter=\t', '--with-nth=1',
        '--expect=ctrl-y', "--header=$header", '--header-first',
        "--color=$colors"
    )
    if ($search) { $fzfArgs += "--query=$search" }

    $out = @($lines | fzf @fzfArgs)
    if ($out.Count -lt 2) { return }

    $pressed = $out[0]
    $x = $list[[int](($out[-1] -split "`t")[-1])]

    # режим F1: вернуть команду для вставки
    if ($Pick) {
        if ($x.Run) { return $x.Run }
        return
    }

    $text = if ($x.Run) { $x.Run.Trim() } else { $x.Key }

    if ($pressed -eq 'ctrl-y') {
        Set-Clipboard -Value $text
        Write-Host "  ${dim}Скопировано:$r $keyc$text$r"
        return
    }

    if (-not $x.Run) {
        Write-Host ''
        Write-Host "  $keyc$($x.Key)$r  $dim$($x.Desc)$r"
        Write-Host ''
        return
    }

    if ($x.Run.EndsWith(' ')) {
        Set-Clipboard -Value $x.Run
        Write-Host "  ${dim}Шаблон скопирован:$r $keyc$($x.Run)$r"
        Write-Host "  ${dim}Вставь Ctrl+Shift+V и допиши. Удобнее: нажми F1 во время набора.$r"
        return
    }

    Write-Host "$accent$([char]0x03BB)$r $keyc$($x.Run)$r"
    [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($x.Run)
    Invoke-Expression $x.Run
}

# F1: открыть шпаргалку и вставить выбранную команду в строку ввода
Set-PSReadLineKeyHandler -Key F1 -BriefDescription 'Cheat' -ScriptBlock {
    $cmd = cheat -Pick
    if ($cmd) { [Microsoft.PowerShell.PSConsoleReadLine]::Insert($cmd) }
}









