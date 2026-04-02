#!/bin/bash
# ============================================================
# initmylinux - Ubuntu 24.04 Server 全自動初始化腳本
# 用法：
#   curl -fsSL https://raw.githubusercontent.com/joshhu/initmylinux/main/setup.sh | bash
#   或者 clone 後執行：bash setup.sh
# ============================================================

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 輸出函式
info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# 取得腳本所在目錄
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 檢查是否為 Ubuntu
if ! grep -qi "ubuntu" /etc/os-release 2>/dev/null; then
    warn "此腳本設計給 Ubuntu 24.04，其他發行版可能有相容性問題"
fi

# 檢查是否有 sudo 權限
if ! sudo -n true 2>/dev/null; then
    info "需要 sudo 權限，請輸入密碼"
    sudo -v || error "無法取得 sudo 權限"
fi

# ============================================================
# 1. 設定主機名稱
# ============================================================
read -p "請輸入主機名稱 (預設: JoshAuto): " HOSTNAME_INPUT
HOSTNAME_INPUT=${HOSTNAME_INPUT:-JoshAuto}
info "設定主機名稱為 ${HOSTNAME_INPUT}..."
sudo hostnamectl set-hostname "$HOSTNAME_INPUT"
ok "主機名稱已設定為 ${HOSTNAME_INPUT}"

# ============================================================
# 2. 修正 DNS（使用 Google 和 Cloudflare DNS）
# ============================================================
info "設定 DNS..."
sudo mkdir -p /etc/systemd/resolved.conf.d
sudo tee /etc/systemd/resolved.conf.d/dns.conf > /dev/null << 'EOF'
[Resolve]
DNS=8.8.8.8 1.1.1.1
FallbackDNS=8.8.4.4
EOF
sudo systemctl restart systemd-resolved
ok "DNS 設定完成 (8.8.8.8 / 1.1.1.1)"

# ============================================================
# 3. 設定語系
# ============================================================
info "安裝中文語系..."
sudo apt update -qq
sudo apt install -y language-pack-zh-hant > /dev/null 2>&1
sudo localectl set-locale LANG=zh_TW.UTF-8
ok "語系已設定為 zh_TW.UTF-8"

# ============================================================
# 4. 安裝基礎套件
# ============================================================
info "安裝基礎套件 (git, curl, zsh, autojump)..."
sudo apt install -y git curl zsh autojump > /dev/null 2>&1
ok "基礎套件安裝完成"

# ============================================================
# 5. 設定 zsh 為預設 shell
# ============================================================
info "設定 zsh 為預設 shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
    ok "zsh 已設為預設 shell（需重新登入生效）"
else
    ok "zsh 已經是預設 shell"
fi

# ============================================================
# 6. 安裝 oh-my-zsh 及插件
# ============================================================
info "安裝 oh-my-zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ok "oh-my-zsh 安裝完成"
else
    ok "oh-my-zsh 已存在，跳過"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

info "安裝 zsh 插件..."
[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ] && \
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
ok "zsh 插件安裝完成"

# ============================================================
# 7. 部署 .zshrc 和主題
# ============================================================
info "部署 .zshrc 和 myclean 主題..."
mkdir -p "$ZSH_CUSTOM/themes"

if [ -f "$SCRIPT_DIR/.zshrc" ]; then
    cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
else
    warn ".zshrc 檔案不存在，從 GitHub 下載..."
    curl -fsSL https://raw.githubusercontent.com/joshhu/initmylinux/main/.zshrc -o "$HOME/.zshrc"
fi

if [ -f "$SCRIPT_DIR/myclean.zsh-theme" ]; then
    cp "$SCRIPT_DIR/myclean.zsh-theme" "$ZSH_CUSTOM/themes/myclean.zsh-theme"
else
    warn "myclean.zsh-theme 檔案不存在，從 GitHub 下載..."
    curl -fsSL https://raw.githubusercontent.com/joshhu/initmylinux/main/myclean.zsh-theme -o "$ZSH_CUSTOM/themes/myclean.zsh-theme"
fi
ok ".zshrc 和主題部署完成"

# ============================================================
# 8. 設定 sudo 免密碼
# ============================================================
info "設定 sudo 免密碼..."
CURRENT_USER=$(whoami)
sudo bash -c "echo '${CURRENT_USER} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/${CURRENT_USER} && chmod 440 /etc/sudoers.d/${CURRENT_USER}"
ok "sudo 免密碼已設定 (${CURRENT_USER})"

# ============================================================
# 9. 安裝開發工具
# ============================================================

# --- uv ---
info "安裝 uv..."
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source "$HOME/.local/bin/env" 2>/dev/null || true
    ok "uv 安裝完成"
else
    ok "uv 已存在，跳過"
fi

# --- nvm ---
info "安裝 nvm..."
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    ok "nvm 安裝完成"
else
    ok "nvm 已存在，跳過"
fi

# --- Homebrew ---
info "安裝 Homebrew..."
if ! command -v brew &>/dev/null && [ ! -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    sudo apt install -y build-essential > /dev/null 2>&1
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    ok "Homebrew 安裝完成"
else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true
    ok "Homebrew 已存在，跳過"
fi

# --- gh ---
info "安裝 gh (GitHub CLI)..."
brew install gh 2>/dev/null || ok "gh 已存在"
ok "gh 安裝完成"

# --- docker ---
info "安裝 Docker..."
if ! command -v docker &>/dev/null; then
    sudo apt install -y docker.io > /dev/null 2>&1
    sudo usermod -aG docker "$(whoami)"
    ok "Docker 安裝完成（需重新登入以套用 docker 群組）"
else
    ok "Docker 已存在，跳過"
fi

# --- ffmpeg / ffprobe ---
info "安裝 ffmpeg / ffprobe..."
sudo apt install -y ffmpeg > /dev/null 2>&1
ok "ffmpeg / ffprobe 安裝完成"

# ============================================================
# 10. 安裝現代化 CLI 工具
# ============================================================
info "安裝系統監控工具 (htop, ncdu, nmap, tmux, fzf, direnv, rsync, wget, httpie)..."
sudo apt install -y \
    htop ncdu ripgrep fd-find bat jq \
    nmap tmux fzf direnv rsync wget curl httpie \
    > /dev/null 2>&1
ok "APT 工具安裝完成"

info "安裝 Homebrew 工具 (btop, duf, eza, yq, lazygit, tldr, glow, mkcert, gcc)..."
brew install gcc btop duf eza yq lazygit tldr glow mkcert 2>/dev/null
ok "Homebrew 工具安裝完成"

# --- tailscale ---
info "安裝 Tailscale..."
if ! command -v tailscale &>/dev/null; then
    curl -fsSL https://tailscale.com/install.sh | sh
    ok "Tailscale 安裝完成（請執行 'sudo tailscale up' 來啟用）"
else
    ok "Tailscale 已存在，跳過"
fi

# ============================================================
# 11. 桌面環境設定 (LightDM + x11vnc)
# ============================================================
info "安裝桌面環境 (LightDM + x11vnc)..."
sudo apt install -y lightdm x11vnc > /dev/null 2>&1
ok "LightDM 和 x11vnc 安裝完成"

# 部署 x11vnc.service
info "設定 x11vnc 為系統服務..."
if [ -f "$SCRIPT_DIR/x11vnc.service" ]; then
    sudo cp "$SCRIPT_DIR/x11vnc.service" /etc/systemd/system/x11vnc.service
else
    warn "x11vnc.service 不存在，從 GitHub 下載..."
    sudo curl -fsSL https://raw.githubusercontent.com/joshhu/initmylinux/main/x11vnc.service -o /etc/systemd/system/x11vnc.service
fi

# 設定 VNC 密碼目錄
mkdir -p "$HOME/.vnc"
info "請設定 x11vnc 密碼："
x11vnc -storepasswd "$HOME/.vnc/passwd"

sudo systemctl daemon-reload
sudo systemctl enable x11vnc.service
sudo systemctl start x11vnc.service
ok "x11vnc 服務已啟動並設定為開機自動啟動"

# 桌面背景改為黑色
info "設定桌面背景為黑色..."
gsettings set org.gnome.desktop.background picture-options 'none' 2>/dev/null || true
gsettings set org.gnome.desktop.background primary-color '#000000' 2>/dev/null || true
ok "桌面背景已設為黑色"

# ============================================================
# 12. 關閉系統休眠
# ============================================================
info "關閉系統休眠..."
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
ok "系統休眠已關閉"

# ============================================================
# 13. 設定別名（Ubuntu 套件名不同）
# ============================================================
if ! grep -q 'alias bat="batcat"' "$HOME/.zshrc"; then
    cat >> "$HOME/.zshrc" << 'EOF'

# Ubuntu 別名（套件名與指令名不同）
alias bat="batcat"
alias fd="fdfind"
EOF
    ok "bat/fd 別名已加入 .zshrc"
fi

# ============================================================
# 完成
# ============================================================
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  initmylinux 初始化完成！${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo "已安裝的工具："
echo "  Shell:    zsh + oh-my-zsh (myclean 主題)"
echo "  插件:     zsh-completions, zsh-syntax-highlighting, zsh-autosuggestions, autojump"
echo "  開發:     uv, nvm, brew, gh, docker, ffmpeg/ffprobe"
echo "  監控:     htop, btop, ncdu, duf"
echo "  檔案:     ripgrep(rg), fd, bat, eza, jq, yq"
echo "  網路:     curl, httpie, wget, mkcert, nmap, tailscale"
echo "  工具:     tmux, fzf, direnv, lazygit, tldr, glow, rsync"
echo "  桌面:     lightdm, x11vnc (VNC 遠端桌面)"
echo ""
echo "系統設定："
echo "  - 桌面背景已設為黑色"
echo "  - 系統休眠已關閉"
echo "  - x11vnc 已設為系統服務 (port 5900)"
echo ""
echo -e "${YELLOW}請重新登入或執行 'exec zsh' 以套用所有設定${NC}"
echo -e "${YELLOW}如需啟用 Tailscale，請執行：sudo tailscale up${NC}"
