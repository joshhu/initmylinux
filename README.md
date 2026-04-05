# initmylinux

Agent Skill — 一鍵初始化 Ubuntu 24.04 Server，打造完整的現代化開發環境。

## 使用方式

本 repo 是一個標準的 Agent Skill，任何支援 skill 的 AI coding agent 都可以使用。只要告訴 agent：

> 幫我初始化 IP 為 x.x.x.x 的 Ubuntu 主機，帳號密碼是 user/pass

Agent 會自動建立 SSH key、設定免密登入，然後執行完整安裝。

## 安裝內容

### 系統設定
- `apt update && apt upgrade` 系統全面更新
- 自訂主機名稱（預設 JoshAuto）
- DNS 設定為 8.8.8.8 / 1.1.1.1
- 語系 `zh_TW.UTF-8`
- sudo 免密碼
- 關閉系統休眠

### Shell 環境
- **zsh** + **oh-my-zsh**
- 自訂主題 **myclean**（顯示主機名、使用者、目錄、git 狀態）
- 插件：`git` `autojump` `zsh-completions` `zsh-syntax-highlighting` `zsh-autosuggestions`

### 開發工具
| 工具 | 說明 |
|------|------|
| [uv](https://github.com/astral-sh/uv) | 超快的 Python 套件管理器 |
| [nvm](https://github.com/nvm-sh/nvm) | Node.js 版本管理 |
| [Homebrew](https://brew.sh/) | Linux 套件管理器 |
| [gh](https://cli.github.com/) | GitHub CLI |
| [Docker](https://www.docker.com/) | 容器引擎 |
| ffmpeg / ffprobe | 多媒體處理 |

### 現代化 CLI 工具

| 分類 | 工具 |
|------|------|
| 系統監控 | htop, btop, ncdu, duf |
| 檔案處理 | ripgrep(rg), fd, bat, eza, jq, yq |
| 網路 | curl, httpie, wget, mkcert, nmap, [tailscale](https://tailscale.com/) |
| 開發 | tmux, fzf, direnv, [lazygit](https://github.com/jesseduffield/lazygit) |
| 其他 | tldr, [glow](https://github.com/charmbracelet/glow), rsync |

### 桌面環境（VNC 遠端桌面）

| 工具 | 說明 |
|------|------|
| LightDM | 輕量桌面管理器 |
| x11vnc | VNC Server（port 5900，開機自啟） |
| Google Chrome / Chromium | 網頁瀏覽器（Chrome 安裝失敗自動改裝 Chromium） |

## Skill 結構

```
skills/initmylinux/
├── SKILL.md              # skill 觸發條件與執行流程
├── scripts/              # 安裝腳本與設定檔
│   ├── setup.sh
│   ├── .zshrc
│   ├── myclean.zsh-theme
│   └── x11vnc.service
└── refs/                 # 參考文件
    └── setup-steps.md    # 15 步安裝細節
```

## 授權

MIT License
