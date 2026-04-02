# initmylinux

一鍵初始化 Ubuntu 24.04 Server 的全自動腳本，打造完整的現代化開發環境。

## 快速開始

### 在目標主機上直接執行

```bash
git clone https://github.com/joshhu/initmylinux.git
cd initmylinux
bash setup.sh
```

### 或者用一行指令

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/joshhu/initmylinux/main/setup.sh)
```

> **注意**：一行指令方式會自動從 GitHub 下載 `.zshrc`、`myclean.zsh-theme` 和 `x11vnc.service`。

### 透過 Claude Code 遠端部署

如果你使用 Claude Code，可以直接告訴它：

> 幫我初始化 IP 為 x.x.x.x 的 Ubuntu 主機，帳號密碼是 user/pass

Claude Code 會自動建立 SSH key、設定免密登入，然後執行完整安裝。

## 安裝了什麼？

### 系統設定
- `apt update && apt upgrade` 系統全面更新
- 自訂主機名稱
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

**系統監控**

| 工具 | 說明 |
|------|------|
| htop / btop | 互動式行程監控 |
| ncdu | 磁碟空間分析 |
| duf | 現代化磁碟使用量 |

**檔案與文字處理**

| 工具 | 說明 |
|------|------|
| ripgrep (rg) | 超快搜尋，取代 grep |
| fd | 現代化 find |
| bat | 語法高亮的 cat |
| eza | 現代化 ls，支援 git 狀態 |
| jq / yq | JSON / YAML 處理 |

**網路與 API**

| 工具 | 說明 |
|------|------|
| curl / httpie | HTTP 請求工具 |
| wget | 檔案下載 |
| mkcert | 本地 HTTPS 憑證 |
| nmap | 網路掃描 |
| [tailscale](https://tailscale.com/) | 零設定 VPN |

**開發工具**

| 工具 | 說明 |
|------|------|
| tmux | Terminal 多視窗管理 |
| fzf | 模糊搜尋 |
| direnv | 自動載入 .env |
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal 圖形化 git |

**其他**

| 工具 | 說明 |
|------|------|
| tldr | 簡化版 man page |
| [glow](https://github.com/charmbracelet/glow) | Terminal Markdown 渲染 |
| rsync | 檔案同步 |

### 桌面環境（VNC 遠端桌面）

| 工具 | 說明 |
|------|------|
| LightDM | 輕量桌面管理器 |
| x11vnc | VNC Server（port 5900，開機自啟） |
| - | 桌面背景設為純黑色 |

## myclean 主題預覽

```
(JoshAuto)joshhu:workspace/ (main✓) $
(JoshAuto)joshhu:project/ (develop✗) $
```

- 主機名稱 + 使用者 + 目前目錄 + git 分支狀態
- root 使用者名稱為紅色，一般使用者為白色
- ✓ 綠色 = clean，✗ 紅色 = dirty

## 檔案結構

```
initmylinux/
├── setup.sh              # 主安裝腳本
├── .zshrc                # zsh 設定檔模板
├── myclean.zsh-theme     # oh-my-zsh 自訂主題
├── x11vnc.service        # x11vnc systemd 服務檔
├── CLAUDE.md             # Claude Code 指令文件
└── README.md             # 本說明文件
```

## 系統需求

- Ubuntu 24.04 Server（其他 Ubuntu/Debian 版本可能也適用）
- 有 sudo 權限的使用者帳號
- 可連線至網際網路

## 授權

MIT License
