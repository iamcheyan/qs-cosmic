# dots-hyprland 使用和自定义说明

这份文档记录当前这套 dots-hyprland / illogical-impulse 配置的日常入口、快捷键、配置文件位置，以及这台 MacBook / Fedora Asahi 上已经做过的关键调整。

## 主要入口

| 操作 | 快捷键 |
| --- | --- |
| 打开快捷键速查 | `Super + /` |
| 打开设置面板 | `Super + I` |
| 打开欢迎/初始设置界面 | `Super + Shift + Alt + /` |
| 重启 Hyprland widgets / Quickshell | `Ctrl + Super + R` |
| 打开终端 | `Super + Enter` / `Super + T` / `Ctrl + Alt + T` |
| 关闭当前窗口 | `Super + Q` |
| 锁屏 | `Super + L` |
| 电源/会话菜单 | `Ctrl + Alt + Delete` |

## 常用功能

| 功能 | 快捷键 |
| --- | --- |
| 工作区总览 | `Super + Tab` |
| 剪贴板历史 | `Super + V` |
| Emoji 选择 | `Super + .` |
| 左侧栏 | `Super + A` |
| 右侧栏 | `Super + N` |
| 媒体控制 | `Super + M` |
| 小组件覆盖层 | `Super + G` |
| 显示/隐藏顶部栏 | `Super + J` |
| 换壁纸 | `Ctrl + Super + T` |
| 随机壁纸 | `Ctrl + Super + Alt + T` |
| 明暗模式切换 | `Ctrl + Super + Shift + D` |
| 切换面板风格 | `Ctrl + Super + P` |

## 截图和工具

| 功能 | 快捷键 |
| --- | --- |
| 区域截图 | `Super + Shift + S` |
| 区域 OCR 到剪贴板 | `Super + Shift + X` |
| 屏幕翻译 | `Super + Shift + T` |
| 取色到剪贴板 | `Super + Shift + C` |
| 区域录屏 | `Super + Shift + R` |
| 全屏截图到剪贴板 | `Print` |
| 全屏截图到文件和剪贴板 | `Ctrl + Print` |

截图文件通常会写到：

```text
~/Pictures/Screenshots/
```

## 窗口操作

| 功能 | 快捷键 |
| --- | --- |
| 移动窗口 | `Super + 鼠标左键拖动` |
| 调整窗口大小 | `Super + 鼠标右键拖动` |
| 聚焦方向窗口 | `Super + 方向键` |
| 移动窗口方向 | `Super + Shift + 方向键` |
| 最大化 | `Super + D` |
| 全屏 | `Super + F` |
| 浮动/平铺切换 | `Super + Alt + Space` |
| 置顶固定 | `Super + P` |
| 强制点选关闭窗口 | `Super + Shift + Alt + Q` |

## 配置文件在哪里

优先改 `custom` 目录，不要直接改 `~/.config/hypr/hyprland/` 里的主体配置。主体配置更像上游文件，更新或重装时更容易被覆盖。

### Hyprland 自定义

```text
~/.config/hypr/custom/general.lua      显示器、缩放、键盘布局、输入设置
~/.config/hypr/custom/keybinds.lua     自定义快捷键
~/.config/hypr/custom/variables.lua    默认应用，比如终端、浏览器、文件管理器
~/.config/hypr/custom/rules.lua        窗口规则
~/.config/hypr/custom/execs.lua        开机自启
~/.config/hypr/custom/env.lua          环境变量
```

改完 Hyprland 配置后执行：

```bash
hyprctl reload
```

### 状态栏 / Quickshell / 外观

主要用户配置：

```text
~/.config/illogical-impulse/config.json
```

这里管状态栏、字体、壁纸、侧边栏、UI 外观、默认 app 等。也可以用图形设置面板：

```text
Super + I
```

改完状态栏或 Quickshell 相关配置后，可以重启：

```bash
killall qs quickshell
qs -c ii &
```

或者按：

```text
Ctrl + Super + R
```

### Quickshell 程序在哪里

Quickshell 主体程序在：

```text
~/.config/quickshell/ii/
```

仓库模板对应位置：

```text
/home/tetsuya/dots-hyprland/dots/.config/quickshell/ii/
```

如果你已经决定之后不跟上游更新，而是自己维护这套配置，那么可以直接把 `~/.config/quickshell/ii/` 当成你的 QML 项目来改。

常见入口：

```text
~/.config/quickshell/ii/shell.qml                         Quickshell 主入口
~/.config/quickshell/ii/settings.qml                      设置面板入口
~/.config/quickshell/ii/welcome.qml                       欢迎/初始设置界面
~/.config/quickshell/ii/GlobalStates.qml                  全局状态
~/.config/quickshell/ii/ReloadPopup.qml                   重载提示
```

外观和共用组件：

```text
~/.config/quickshell/ii/modules/common/Appearance.qml     全局颜色、字体、圆角、尺寸
~/.config/quickshell/ii/modules/common/Config.qml         默认配置结构
~/.config/quickshell/ii/modules/common/Icons.qml          图标映射
~/.config/quickshell/ii/modules/common/widgets/           通用控件
~/.config/quickshell/ii/assets/icons/                     内置图标
~/.config/quickshell/ii/assets/images/                    内置图片
```

顶部栏和主要界面：

```text
~/.config/quickshell/ii/modules/ii/bar/                   顶部状态栏
~/.config/quickshell/ii/modules/ii/sidebarLeft/           左侧栏
~/.config/quickshell/ii/modules/ii/sidebarRight/          右侧栏
~/.config/quickshell/ii/modules/ii/overview/              工作区总览
~/.config/quickshell/ii/modules/ii/wallpaperSelector/     壁纸选择器
~/.config/quickshell/ii/modules/ii/sessionScreen/         电源/会话菜单
~/.config/quickshell/ii/modules/ii/lock/                  锁屏
~/.config/quickshell/ii/modules/ii/background/            桌面背景组件
~/.config/quickshell/ii/modules/ii/mediaControls/         媒体控制
~/.config/quickshell/ii/modules/ii/notificationPopup/     通知弹窗
~/.config/quickshell/ii/modules/ii/onScreenDisplay/       音量/亮度 OSD
```

如果只是想改顶部状态栏，优先看：

```text
~/.config/quickshell/ii/modules/ii/bar/BarContent.qml
~/.config/quickshell/ii/modules/ii/bar/Bar.qml
~/.config/quickshell/ii/modules/ii/bar/Workspaces.qml
~/.config/quickshell/ii/modules/ii/bar/ClockWidget.qml
~/.config/quickshell/ii/modules/ii/bar/BatteryIndicator.qml
~/.config/quickshell/ii/modules/ii/bar/Resources.qml
~/.config/quickshell/ii/modules/ii/bar/UtilButtons.qml
```

改完 Quickshell QML 后重启：

```bash
killall qs quickshell
qs -c ii &
```

也可以按：

```text
Ctrl + Super + R
```

如果你要长期自己维护，建议把 live 配置和仓库模板保持同步。比如你改了 live 的 Quickshell：

```bash
rsync -a --delete ~/.config/quickshell/ii/ /home/tetsuya/dots-hyprland/dots/.config/quickshell/ii/
```

如果你改了仓库模板，想同步回 live：

```bash
rsync -a --delete /home/tetsuya/dots-hyprland/dots/.config/quickshell/ii/ ~/.config/quickshell/ii/
killall qs quickshell
qs -c ii &
```

注意：上面用了 `--delete`，会让目标目录和源目录完全一致。执行前确认方向不要写反。

自己维护后，建议不要再直接跑会覆盖配置的完整安装步骤。如果以后要更新依赖，尽量只用系统包管理器更新依赖，不要让上游 dotfiles 覆盖你的 QML：

```bash
sudo dnf upgrade --refresh
```

如果仍然要从仓库更新代码，先备份：

```bash
cp -a ~/.config/quickshell/ii ~/.config/quickshell/ii.backup.$(date +%F-%H%M%S)
cp -a ~/.config/hypr ~/.config/hypr.backup.$(date +%F-%H%M%S)
cp -a ~/.config/illogical-impulse ~/.config/illogical-impulse.backup.$(date +%F-%H%M%S)
```

### 终端

```text
~/.config/kitty/kitty.conf
~/.config/foot/foot.ini
~/.local/share/konsole/Profile 1.profile
```

当前已把默认 shell 改回 `zsh`：

```text
kitty:   shell zsh
foot:    shell=zsh
konsole: Command=/bin/zsh
```

### 不建议优先改的目录

```text
~/.config/hypr/hyprland/
~/.config/quickshell/ii/
```

这些是主体配置。能改，但不推荐作为日常自定义入口。能放到 `~/.config/hypr/custom/` 或 `~/.config/illogical-impulse/config.json` 的改动，优先放那里。

## 当前这台机器的关键配置

当前内屏：

```text
输出名: eDP-1
分辨率: 3024x1890
刷新率: 120Hz
缩放: 2
```

配置位置：

```text
~/.config/hypr/custom/general.lua
```

当前内容包含：

```lua
hl.monitor({
    output = "eDP-1",
    mode = "3024x1890@120",
    position = "0x0",
    scale = 2
})

hl.config({
    input = {
        kb_layout = "jp",
        kb_model = "jp106"
    }
})
```

如果你想临时测试缩放，不改文件，可以用 Lua parser 的写法：

```bash
hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "3024x1890@120", position = "0x0", scale = 1.75 })'
```

常用缩放参考：

```text
1.5   更小，空间更多
1.75  中间
2     MacBook 14 通常比较正常
2.25  更大
```

注意：这套配置使用 Hyprland Lua / non-legacy parser，所以旧写法不可用：

```bash
hyprctl keyword monitor ',preferred,auto,2'
```

它会报：

```text
keyword can't work with non-legacy parsers. Use eval.
```

## 字体和图标

状态栏图标主要依赖：

```text
Material Symbols Rounded
Ubuntu Nerd Font
```

如果顶部栏出现 `memory`、`volume_up`、`calendar_month` 这种英文文本，而不是图标，通常是图标字体没加载。

检查字体：

```bash
fc-match 'Material Symbols Rounded'
fc-match 'Ubuntu Nerd Font'
```

当前已安装用户级 Material Symbols 到：

```text
~/.local/share/fonts/material-symbols/MaterialSymbolsRounded.ttf
```

刷新字体缓存：

```bash
fc-cache -fv ~/.local/share/fonts
```

然后重启 Quickshell：

```bash
killall qs quickshell
qs -c ii &
```

## 文档和参考

本地还有几份原有文档：

```text
~/.config/hypr/docs/app-icons.md
~/.config/hypr/docs/window-switcher.md
~/.config/hypr/docs/workspace-overview.md
```

项目文档入口：

```text
https://ii.clsty.link
```

仓库里的 Fedora 说明：

```text
/home/tetsuya/dots-hyprland/sdata/dist-fedora/README.md
```

## 更新和重装注意

你现在有两份相关文件：

```text
live 配置: ~/.config/hypr/docs/dots-hyprland-user-guide.md
仓库模板: /home/tetsuya/dots-hyprland/dots/.config/hypr/docs/dots-hyprland-user-guide.md
```

日常看 live 配置那份就行。仓库模板那份用于以后重新同步 dotfiles。

如果重新跑安装脚本，注意这台机器是 Fedora Asahi / arm64。不要盲目安装 x86_64 的预构建 RPM。之前为了避开这个问题，依赖尽量使用 Fedora / COPR 的 aarch64 包，Material Symbols 则用用户级字体安装。
