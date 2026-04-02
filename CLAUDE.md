# initmylinux - Ubuntu 24.04 Server 自動初始化

## 專案說明
這是一個自動化腳本，用於初始化全新的 Ubuntu 24.04 Server，包含完整的開發環境設定。

## 使用方式

### 方法一：直接在目標主機上執行
```bash
git clone https://github.com/joshhu/initmylinux.git
cd initmylinux
bash setup.sh
```

### 方法二：透過 Claude Code Agent Skill 從本機遠端部署
提供目標主機的 IP、帳號、密碼，Claude Code 會自動：
1. 建立 SSH key 並設定免密登入
2. 設定 sudo 免密碼
3. 執行 setup.sh 完成所有安裝

## 安裝內容

### 系統設定
- apt update && apt upgrade（系統全面更新）
- 主機名稱（可自訂，預設 JoshAuto）
- DNS：8.8.8.8 / 1.1.1.1
- 語系：zh_TW.UTF-8
- sudo 免密碼
- 關閉系統休眠（mask sleep/suspend/hibernate/hybrid-sleep）

### Shell 環境
- zsh + oh-my-zsh
- 主題：myclean（自訂主題，含 git 狀態顯示）
- 插件：git, autojump, zsh-completions, zsh-syntax-highlighting, zsh-autosuggestions

### 開發工具
1. uv — Python 套件管理器
2. nvm — Node.js 版本管理
3. brew — Homebrew 套件管理
4. gh — GitHub CLI
5. docker — 容器引擎
6. ffmpeg / ffprobe — 多媒體處理

### 現代化 CLI 工具
| 分類 | 工具 |
|------|------|
| 系統監控 | htop, btop, ncdu, duf |
| 檔案處理 | ripgrep(rg), fd, bat, eza, jq, yq |
| 網路 | curl, httpie, wget, mkcert, nmap, tailscale |
| 開發 | tmux, fzf, direnv, lazygit |
| 其他 | tldr, glow, rsync |

### 桌面環境（VNC 遠端桌面）
- LightDM 桌面管理器
- x11vnc VNC Server（port 5900，開機自啟）
- 桌面背景設為純黑色
- x11vnc.service 系統服務檔

## 檔案結構
```
initmylinux/
├── setup.sh              # 主安裝腳本
├── .zshrc                # zsh 設定檔
├── myclean.zsh-theme     # oh-my-zsh 自訂主題
├── x11vnc.service        # x11vnc systemd 服務檔
├── CLAUDE.md             # Claude Code 指令文件
└── README.md             # 說明文件
```

## oh-my-zsh 主題 (myclean)
- 顯示格式：`(主機名)使用者:目前目錄/ (git分支✓/✗) $`
- root 使用者名稱為紅色，一般使用者為白色
- git 分支名稱為黃色，clean 為綠色 ✓，dirty 為紅色 ✗
- 自訂 LS_COLORS 配色

## .zshrc 設定
- 主題：myclean
- 大小寫敏感補全
- 插件：git, autojump, zsh-completions, zsh-syntax-highlighting, zsh-autosuggestions
- CUDA 路徑支援
- uv / nvm / brew 環境變數
- bat → batcat、fd → fdfind 別名（Ubuntu 相容）
- tmux UTF-8 模式別名
