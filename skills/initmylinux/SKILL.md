---
name: initmylinux
description: >
  This skill should be used when the user asks to "初始化 Linux",
  "init my linux", "setup ubuntu", "設定新的 Linux 主機",
  "幫我裝好 Linux", "initmylinux", "初始化 Ubuntu",
  or provides a Linux host IP with credentials for remote setup.
  Automates full Ubuntu 24.04 Server initialization including
  SSH key setup, system configuration, dev tools, and VNC desktop.
---

# initmylinux - Ubuntu 24.04 Server 全自動初始化

## 概述

將全新的 Ubuntu 24.04 Server 從零初始化為完整的開發環境。
支援本機直接執行或透過 SSH 遠端部署。

## 觸發條件

當使用者提供目標主機的 IP、帳號、密碼，或要求初始化一台新的 Ubuntu Linux 主機時啟用。

## 執行流程

### 模式一：遠端部署（使用者提供 IP + 帳密）

1. **建立 SSH 免密連線**
   - 產生 ed25519 SSH key（名稱依主機名稱命名）
   - 使用 SSH_ASKPASS 技巧自動將公鑰傳送到遠端
   - 在本機 `~/.ssh/config` 中新增 Host 別名
   - 驗證免密登入正常運作

2. **設定 sudo 免密碼**
   - 透過 SSH 建立 `/etc/sudoers.d/<username>` 檔案
   - 設定 `NOPASSWD:ALL`

3. **Clone 並執行安裝腳本**
   - 在遠端 clone `https://github.com/joshhu/initmylinux.git`
   - 分段非互動式執行 `setup.sh`（跳過互動式 `read` 和密碼設定步驟，改由參數傳入）

### 模式二：本機直接執行

引導使用者在目標主機上執行：
```bash
git clone https://github.com/joshhu/initmylinux.git
cd initmylinux
bash setup.sh
```

## 安裝步驟詳解

詳細的 14 個安裝步驟請參考 `references/setup-steps.md`。

摘要如下：

| 步驟 | 內容 |
|------|------|
| 1 | 設定主機名稱 |
| 2 | 修正 DNS (8.8.8.8 / 1.1.1.1) |
| 3 | apt update && apt upgrade |
| 4 | 設定語系 zh_TW.UTF-8 |
| 5 | 安裝基礎套件 (git, curl, zsh, autojump) |
| 6 | 設定 zsh 為預設 shell |
| 7 | 安裝 oh-my-zsh + 插件 |
| 8 | 部署 .zshrc + myclean 主題 |
| 9 | 設定 sudo 免密碼 |
| 10 | 安裝開發工具 (uv, nvm, brew, gh, docker, ffmpeg) |
| 11 | 安裝現代化 CLI 工具 + tailscale |
| 12 | 桌面環境 (LightDM + x11vnc) |
| 13 | 安裝 Google Chrome |
| 14 | 關閉系統休眠 |
| 15 | 設定 Ubuntu 別名 (bat/fd) |

## 設定檔來源

安裝腳本和設定檔皆來自 GitHub repo：

- `setup.sh` — 主安裝腳本
- `.zshrc` — zsh 設定檔（myclean 主題、插件、PATH）
- `myclean.zsh-theme` — 自訂 oh-my-zsh 主題
- `x11vnc.service` — x11vnc systemd 服務檔

## 遠端部署注意事項

- 使用 `SSH_ASKPASS` + `SSH_ASKPASS_REQUIRE=force` 傳送密碼，避免互動式輸入
- DNS 修正必須在安裝任何網路套件之前完成（使用 systemd-resolved 永久設定）
- `chsh` 指令不可用 sudo，否則只會改到 root
- Docker 安裝後需將使用者加入 docker 群組
- x11vnc 密碼用 `x11vnc -storepasswd <password> ~/.vnc/passwd` 非互動式設定
- `apt upgrade` 使用 `-y` 自動確認

## 驗證

安裝完成後，執行全面驗證，確認每個工具都可正常使用。
以表格方式向使用者回報結果。

## Additional Resources

### Reference Files

- **`references/setup-steps.md`** — 完整 14 步驟安裝細節與指令
