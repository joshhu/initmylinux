# initmylinux 安裝步驟詳解

## 步驟 1：設定主機名稱

```bash
sudo hostnamectl set-hostname <HOSTNAME>
```

預設名稱為 `JoshAuto`，可由使用者自訂。

## 步驟 2：修正 DNS

建立永久性 DNS 設定，避免 systemd-resolved 覆蓋：

```bash
sudo mkdir -p /etc/systemd/resolved.conf.d
sudo tee /etc/systemd/resolved.conf.d/dns.conf > /dev/null << 'EOF'
[Resolve]
DNS=8.8.8.8 1.1.1.1
FallbackDNS=8.8.4.4
EOF
sudo systemctl restart systemd-resolved
```

此步驟必須在安裝任何需要網路下載的套件之前完成。

## 步驟 3：系統全面更新

```bash
sudo apt update -qq
sudo apt upgrade -y
```

## 步驟 4：設定語系

```bash
sudo apt install -y language-pack-zh-hant
sudo localectl set-locale LANG=zh_TW.UTF-8
```

## 步驟 5：安裝基礎套件

```bash
sudo apt install -y git curl zsh autojump
```

## 步驟 6：設定 zsh 為預設 shell

```bash
chsh -s $(which zsh)
```

注意：不可使用 sudo，否則只會改到 root 的 shell。
遠端部署時可能需要用 `echo '<password>' | chsh -s $(which zsh)` 傳入密碼。

## 步驟 7：安裝 oh-my-zsh 及插件

```bash
# oh-my-zsh（非互動模式）
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 插件
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
```

## 步驟 8：部署 .zshrc 和主題

從 repo 中複製設定檔：

```bash
cp .zshrc ~/
mkdir -p "$ZSH_CUSTOM/themes"
cp myclean.zsh-theme "$ZSH_CUSTOM/themes/"
```

### myclean 主題特色
- 格式：`(主機名)使用者:目錄/ (git分支✓/✗) $`
- root 紅色、一般使用者白色
- git clean 綠色 ✓、dirty 紅色 ✗

### .zshrc 重點設定
- 主題：myclean
- 插件：git, autojump, zsh-completions, zsh-syntax-highlighting, zsh-autosuggestions
- CUDA 路徑
- uv / nvm / brew 環境
- `alias tmux='tmux -u'`
- `unsetopt correct_all` / `unsetopt correct`

## 步驟 9：設定 sudo 免密碼

```bash
CURRENT_USER=$(whoami)
sudo bash -c "echo '${CURRENT_USER} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/${CURRENT_USER} && chmod 440 /etc/sudoers.d/${CURRENT_USER}"
```

## 步驟 10：安裝開發工具

### uv (Python 套件管理器)
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### nvm (Node.js 版本管理)
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```

### Homebrew
```bash
sudo apt install -y build-essential
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

### gh (GitHub CLI)
```bash
brew install gh
```

### Docker
```bash
sudo apt install -y docker.io
sudo usermod -aG docker $(whoami)
```

### ffmpeg / ffprobe
```bash
sudo apt install -y ffmpeg
```

## 步驟 11：安裝現代化 CLI 工具

### 透過 APT
```bash
sudo apt install -y htop ncdu ripgrep fd-find bat jq nmap tmux fzf direnv rsync wget curl httpie
```

### 透過 Homebrew
```bash
brew install gcc btop duf eza yq lazygit tldr glow mkcert
```

### Tailscale
```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

安裝後需執行 `sudo tailscale up` 啟用。

## 步驟 12：桌面環境 (LightDM + x11vnc)

```bash
# 安裝
sudo apt install -y lightdm x11vnc

# 部署 x11vnc.service
sudo cp x11vnc.service /etc/systemd/system/

# 設定 VNC 密碼
mkdir -p ~/.vnc
x11vnc -storepasswd <password> ~/.vnc/passwd

# 啟動服務
sudo systemctl daemon-reload
sudo systemctl enable x11vnc.service
sudo systemctl start x11vnc.service

# 桌面背景改黑色
gsettings set org.gnome.desktop.background picture-options 'none'
gsettings set org.gnome.desktop.background primary-color '#000000'
```

### x11vnc.service 內容
```ini
[Unit]
Description=x11vnc VNC Server
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -display :0 -auth guess -forever -loop -noxdamage -repeat -rfbauth /home/%i/.vnc/passwd -rfbport 5900 -shared
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
```

## 步驟 13：關閉系統休眠

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

## 步驟 14：設定 Ubuntu 別名

Ubuntu 中部分套件名與指令名不同，需加別名：

```bash
alias bat="batcat"
alias fd="fdfind"
```

這些別名會被追加到 `~/.zshrc`。
