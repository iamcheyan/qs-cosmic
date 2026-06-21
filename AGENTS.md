# qs-cosmic

Unified repository for a Quickshell + Hyprland desktop shell. Replaces the
former split setup (`iamcheyan/ii` for quickshell, `dotfiles/TWM/hyprland`
submodule for hyprland).

## Layout

```
~/.config/quickshell/          (repo root, git managed)
├── ii/                        quickshell config (entry: shell.qml)
│   ├── shell.qml              ShellRoot, imports modules/services/panelFamilies
│   ├── modules/
│   │   ├── common/            shared widgets, functions, models
│   │   ├── ii/                desktop-shell panels (bar, overview, appLauncher, ...)
│   │   └── settings/          in-shell settings pages
│   ├── services/              QML singleton services (Audio, Notifications, ...)
│   ├── panelFamilies/         panel loaders; IllogicalImpulseFamily.qml ties it together
│   ├── assets/                icons, images
│   ├── translations/          i18n JSON
│   └── scripts/               shell-side helper scripts (colors, keyring, ...)
├── hypr/                      hyprland config (real directory)
│   ├── hyprland.lua           entry point; sources hyprland/ + custom/ subfolders
│   ├── hyprland/              default config modules (env, execs, keybinds, rules, ...)
│   ├── custom/                user overrides (loaded after defaults, keep updates clean)
│   ├── scripts/               shell launcher + helpers (quickshell, screenshot, ...)
│   ├── autostart.sh           legacy autostart (not used by lua config; execs.lua is)
│   └── setup.sh               one-shot installer (creates symlinks, installs deps)
└── docs/
```

`~/.config/hypr` is a symlink to `./hypr`. Do not break this link.

## Runtime

- Hyprland loads `~/.config/hypr/hyprland.lua` (i.e. `hypr/hyprland.lua`).
  Hyprland >= 0.55 uses Lua; the old `hyprland.conf` is a stub.
- Quickshell is launched by `hypr/scripts/quickshell` as
  `/usr/bin/quickshell -p ~/.config/quickshell/ii`. The script also sets
  `QS_CONFIG_DIR` and `QS_COMPOSITOR=hyprland`, and dedups via `pgrep`.
- Autostart lives in `hypr/hyprland/execs.lua` under
  `hl.on("hyprland.start", function() ... end)`. Do NOT wrap launcher calls in
  `bash -c 'pgrep ... || launcher'`: pgrep matches its own bash command line and
  the launcher never runs. Call `hl.exec_cmd("$HOME/.config/hypr/scripts/quickshell")`
  directly; the script self-dedups safely.

## Editing conventions

### Hyprland (Lua)
- Put personal tweaks in `hypr/custom/*.lua`, not in `hypr/hyprland/*.lua`.
  `hyprland.lua` loads `custom.` *after* the defaults so overrides win, and
  keeping defaults untouched makes upstream merges trivial.
- `custom/variables.lua`, `custom/general.lua`, `custom/keybinds.lua`,
  `custom/rules.lua`, `custom/env.lua`, `custom/execs.lua` are all supported.
- API surface: `hl.env`, `hl.config`, `hl.monitor`, `hl.bind`,
  `hl.exec_cmd`, `hl.on(event, fn)`, `hl.layer_rule`, `hl.dsp.*` (dispatchers).

### Quickshell (QML)
- Shared widgets live in `ii/modules/common/widgets/`. Reuse `MaterialSymbol`,
  `StyledText`, `RippleButton`, `IconImage`, etc. before rolling new ones.
- `IconImage` loads asynchronously. For placeholder/fallback, gate on
  `status === Image.Null || status === Image.Error` — NOT `!== Image.Ready`,
  which flashes the placeholder during normal async loading.
- `Quickshell.iconPath(name, true)` resolves a freedesktop icon name to a path.
  Prefix absolute paths with `file://` for `Image.source`.
- Services are QML singletons imported via `import qs.services`.
- The shell hot-reloads on file save; no manual restart needed for QML edits.

## Verification

- `hyprctl reload` — reload hyprland Lua config (no restart required).
- Quickshell reloads automatically; to force: `killall qs; ~/.config/hypr/scripts/quickshell &`
- Check logs:
  - Hyprland: `$XDG_RUNTIME_DIR/hypr/<sig>/hyprland.log`
  - Quickshell: `$XDG_RUNTIME_DIR/quickshell-hyprland.log` (only if launched via `autostart.sh`)

## Environment

Key vars exported by `hypr/hyprland/env.lua` and `hypr/hyprland/variables.lua`:
- `qsConfig=ii` — selects `~/.config/quickshell/$qsConfig` as the config dir.
- `QS_COMPOSITOR=hyprland`, `QS_CONFIG_DIR=~/.config/quickshell/ii`.
- `ILLOGICAL_IMPULSE_VIRTUAL_ENV=~/.local/state/quickshell/.venv` — optional
  python venv for quickshell helper scripts.

## Git

- Remote: `github.com/iamcheyan/qs-cosmic`, branch `main`.
- `ii/.state/` is runtime state (pinned apps, etc.) and is gitignored.
- No test framework; verify changes by reloading and using the shell.
