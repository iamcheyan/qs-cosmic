# Bar 右侧模块自定义：声明式模块列表

## 目标

让用户像 waybar 的 `modules-right` 一样，在 `config.json` 里通过
一个数组自定义 bar 右侧从托盘开始的模块顺序和开关。

## 设计

### 配置

```json
"bar": {
  "rightModules": [
    "weather",
    "systray",
    "media",
    "battery",
    "util:bluetooth",
    "util:wifi",
    "util:clipboard",
    "util:screenshot",
    "util:colorpicker",
    "util:mic",
    "util:nightlight",
    "util:idle",
    "util:audio",
    "sidebar"
  ]
}
```

- 数组顺序 = 从左到右的显示顺序（bar 右侧区域内）
- 模块在数组里 = 显示；不在 = 隐藏。无需额外 `showXxx` 开关
- `util:` 前缀 = UtilButtons 里拆出来的工具按钮

### 模块注册表

`ii/modules/ii/bar/RightModuleRegistry.qml` 维护 `name → Component` 映射：

| name | Component | 说明 |
|---|---|---|
| `weather` | WeatherBar | 天气 |
| `systray` | SysTray | 系统托盘 |
| `media` | Media | 媒体控制 |
| `battery` | BatteryIndicator | 电池 |
| `util:bluetooth` | CircleUtilButton | 蓝牙对话框 |
| `util:wifi` | CircleUtilButton | WiFi 对话框 |
| `util:clipboard` | CircleUtilButton | 剪贴板对话框 |
| `util:screenshot` | RippleButton | 截图 |
| `util:colorpicker` | CircleUtilButton | 取色器 |
| `util:mic` | CircleUtilButton | 麦克风静音 |
| `util:nightlight` | CircleUtilButton | 夜灯 |
| `util:idle` | CircleUtilButton | 阻止自动休眠 |
| `util:audio` | CircleUtilButton | 音量对话框 |
| `sidebar` | RippleButton | 右侧边栏按钮（音量/麦克风静音/键盘布局/通知/电源指示） |
| `spacer` | Item | 占位弹性空间（fillWidth） |

### 渲染

`BarContent.qml` 右侧区域用 `Repeater` 遍历 `rightModules`，从注册表
取 Component 实例化。`layoutDirection: Qt.RightToLeft` 保持不变
（数组从左到右 = 视觉上从托盘往右排列）。

### 与现有配置的关系

- `Config.options.bar.utilButtons.showScreenSnip` 等开关**废弃**，
  改由模块是否在 `rightModules` 数组里决定
- `Config.options.bar.verbose`（控制 UtilButtons 整体显隐）废弃
- `Config.options.bar.weather.enable` 保留（控制 WeatherBar 内部
  是否拉取数据），但模块是否显示由 `rightModules` 决定

### 设置 UI

BarConfig 里：
- 显示可用模块清单（带说明）
- 提供一个可拖拽排序的 ListView，结果写回 `rightModules`
- 或至少提供文本编辑 + 预览

## 实现步骤

1. 创建 `RightModuleRegistry.qml`
2. `Config.qml` 添加 `rightModules` 数组（默认 = 当前顺序）
3. `BarContent.qml` 右侧用 Repeater 替换写死的模块
4. 拆 `UtilButtons.qml` 里的按钮为独立 Component
5. 更新 BarConfig 设置 UI
6. 清理废弃的 `showXxx` 配置