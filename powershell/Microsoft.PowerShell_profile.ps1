# =====================================================================
#  Профиль PowerShell (dzubokko)
# =====================================================================


# --- Предсказания при вводе -------------------------------------------
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineOption -Colors @{ InlinePrediction = "DarkGray" }

# Tab показывает меню вариантов, как в Linux
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Стрелки вверх/вниз ищут по истории с учётом уже набранного
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward


# --- Приглашение ------------------------------------------------------
function prompt {
    $path = $PWD.Path.Replace($HOME, '~')
    $top = [char]0x250C   # ┌
    $bot = [char]0x2514   # └
    Write-Host "$top[" -NoNewline -ForegroundColor DarkGray
    Write-Host $env:USERNAME -NoNewline -ForegroundColor Gray
    Write-Host "]" -ForegroundColor DarkGray
    Write-Host "$bot[" -NoNewline -ForegroundColor DarkGray
    Write-Host $path -NoNewline -ForegroundColor Gray
    Write-Host "]" -ForegroundColor DarkGray
    return "$([char]0x03BB) "
}


# --- Утилиты (подключаются, только если установлены) ------------------

# zoxide: умный cd (z <слово>, zi)
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# eza: минималистичный ls
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    $env:EZA_COLORS = "di=38;2;190;163;199:fi=38;2;210;205;215:da=38;2;110;110;120:sn=38;2;150;150;160:sb=38;2;110;110;120"
    $global:ezaBase = @('--group-directories-first', '--classify', '--no-quotes')
    function ls { eza @ezaBase @args }
    function ll { eza -l --no-permissions --no-user --git @ezaBase @args }
    function la { eza -la --no-permissions --no-user @ezaBase @args }
    function lt { eza --tree --level=2 @ezaBase @args }
}
# fzf: Ctrl+R поиск по истории, Ctrl+T вставить путь к файлу
if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Get-Module -ListAvailable PSFzf)) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# fastfetch при запуске терминала (удали этот блок, если надоест)
$ffConfig = "$HOME\.config\fastfetch\config.jsonc"
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    if (Test-Path $ffConfig) { fastfetch --config $ffConfig } else { fastfetch }
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
    $accent = "$e[38;2;190;163;199m"
    $keyc   = "$e[38;2;248;242;245m"
    $dim    = "$e[38;2;130;130;140m"
    $secc   = "$e[38;2;110;110;120m"
    $runc   = "$e[38;2;150;200;160m"
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
    $colors = 'fg:#a8a3ad,fg+:#f8f2f5,bg+:#1d1a22,hl:#bea3c7,hl+:#bea3c7,prompt:#bea3c7,pointer:#bea3c7,border:#3d3845,header:#6e6e78,info:#6e6e78,label:#bea3c7,query:#f8f2f5'

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


