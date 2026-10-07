# win11-config

Мой Windows 11: тайлинг окон, минималистичный бар, красивый терминал. Тема Catppuccin Mocha.

## Состав

| Компонент | Что делает | Где |
|---|---|---|
| **GlazeWM** | плиточный оконный менеджер, 9 рабочих столов | `glazewm/` |
| **YASB** | верхний бар: столы, таймер, часы, погода, громкость, CPU, память | `yasb/` |
| **WezTerm** | терминал: прозрачность, Iosevka, Catppuccin | `wezterm/` |
| **PowerShell 7** | приглашение с git, подсветка, подсказки, шпаргалка, заметки | `powershell/` |
| **fastfetch** | компактная информация о системе при запуске | `fastfetch/` |
| **ExplorerBlurMica** | прозрачный проводник с размытием | `explorerblurmica/` |
| **Iosevka Custom** | план сборки шрифта | `fonts/` |

Утилиты: eza, zoxide, fzf + PSFzf, bat, btop, lazygit, PowerToys, Windhawk (панель в стиле RosePine, цвета Catppuccin).

## Главное

- `cheat` — интерактивная шпаргалка по всем хоткеям и командам, **F1** — вставить команду в строку
- **Alt+Enter** терминал · **Alt+E** проводник · **Alt+B** браузер · **Alt+1…9** рабочие столы
- **Alt+H/J/K/L** фокус · **Alt+Shift+H/J/K/L** перемещение окон · **Alt+Shift+R** перечитать конфиг
- `z папка` — прыжок в папку · `ll` — список файлов · **Ctrl+R** — поиск по истории
- `i`, `t`, `td`, `j`, `n`, `ns` — заметки, задачи и дневник в терминале

## Установка на новый компьютер

1. Включить режим разработчика: Параметры → Система → Для разработчиков.
2. Установить Git и PowerShell 7:
```powershell
   winget install Git.Git Microsoft.PowerShell
```
3. В PowerShell 7:
```powershell
   git clone https://github.com/dzubokko/win11-config.git ~\dotfiles
   cd ~\dotfiles
   .\install.ps1
```
4. Выполнить ручные шаги, которые покажет скрипт в конце.

Конфиги подключены символическими ссылками: правишь файл на месте, изменения сразу в репозитории.

## Панель задач (Windhawk)

Стиль RosePine в цветах Catppuccin Mocha. Настройки лежат в `windhawk/`.

| Мод | Файл | Куда вставить |
|---|---|---|
| Windows 11 Taskbar Styler | `taskbar-styler.yaml` | Настройки → текстовый режим |
| Taskbar height and icon size | `taskbar-icon-size.json` | Дополнительно → настройки модификации |
| Taskbar Clock Customization | `taskbar-clock.json` | Дополнительно → настройки модификации |
| Taskbar Labels for Windows 11 | `taskbar-labels.json` | Дополнительно → настройки модификации |

Скопировать файл в буфер: `whcopy styler`, `whcopy size`, `whcopy clock`, `whcopy labels`.
