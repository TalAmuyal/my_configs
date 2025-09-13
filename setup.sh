#!/bin/bash

set -euo pipefail # Stop on first error

PUBLIC_CONFIGS_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
WORK_CONFIGS_PATH=~/.local/work_configs

WORKSPACE_DIR_PATH="$HOME/workspace"

source "$PUBLIC_CONFIGS_PATH/_setup/machine_ownership.sh"
source "$PUBLIC_CONFIGS_PATH/_setup/platform.sh"
source "$PUBLIC_CONFIGS_PATH/_setup/ui.sh"


assert_app_present() {
	app="$1"
	capitalized_name="$(tr '[:lower:]' '[:upper:]' <<< ${app:0:1})${app:1}"
	if hash "$app" 2>/dev/null; then
		echo "[V] $capitalized_name found"
	else
		echo "[X] $capitalized_name not found"
		exit 1
	fi
}

echo "This script requires root permissions."
sudo echo "Thanks"

# Create known_hosts and ssh config with proper permissions if missing
[ -e ~/.ssh ] || (mkdir ~/.ssh && chmod 700 ~/.ssh)
[ -e ~/.ssh/known_hosts ] || (touch ~/.ssh/known_hosts && chmod 600 ~/.ssh/known_hosts)
[ -e ~/.ssh/config ] || (touch ~/.ssh/config && chmod 600 ~/.ssh/config)

GITHUB_FINGERPRINT="SHA256:uNiVztksCsDhcc0u9e8BujQXVUpKZIDTMczCvj3tD2s"
if ! grep -q "$GITHUB_FINGERPRINT" ~/.ssh/known_hosts; then
	title "Adding GitHub SSH key fingerprint to known hosts"
	echo "github.com $GITHUB_FINGERPRINT" >> ~/.ssh/known_hosts
fi

if [ ! -e ~/.ssh/github_id ]; then
	title "Setting up GitHub SSH keys"
	ssh-keygen -t rsa -b 4096 -C "GitHub" -f ~/.ssh/github_id
	echo "Add the public key to GitHub:"
	echo ""
	cat ~/.ssh/github_id.pub
	echo ""
	read -p "Press enter when done"
fi

if ! grep -q "github.com" ~/.ssh/config; then
	title "Adding GitHub SSH key to SSH config"
	echo "Host github.com" >> ~/.ssh/config
	echo "  IdentityFile ~/.ssh/github_id" >> ~/.ssh/config
	echo "  User git" >> ~/.ssh/config
	echo "  AddKeysToAgent yes" >> ~/.ssh/config
	echo "  PreferredAuthentications publickey" >> ~/.ssh/config
fi

if `is_work_machine` ; then
	title "Cloning work configs repository"
	[ -d $WORK_CONFIGS_PATH ] && \
		echo "Already cloned." || \
		(git clone git@github.com:TalAmuyal/work_configs.git $WORK_CONFIGS_PATH)
elif `is_personal_machine` ; then
	title "Making default dirs"
	DEFAULT_DIRS=( "$WORKSPACE_DIR_PATH" )
	for i in "${DEFAULT_DIRS[@]}"
	do
		:
			echo -n " - \"$i\" "
			[ -d "$i" ] && echo "already exists" || (mkdir -p "$i" ; ([ -d "$i" ] && echo "created" || (echo "failed to create")))
	done
fi


if `is_osx` ; then
	if ! hash brew 2>/dev/null; then
		title "Installing Homebrew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		eval "$(/opt/homebrew/bin/brew shellenv)"
	fi
elif `is_ubuntu` ; then
	title "Updating packages cache"
	sudo apt update

	title "Upgrading installed packages"
	sudo apt upgrade --assume-yes
fi

title "Installing OS packages"
if `is_osx` ; then
	brew bundle install "--file=$PUBLIC_CONFIGS_PATH/brewfile"
elif `is_arch`; then
	sudo pacman --noconfirm -S --needed $(comm -12 <(pacman -Slq | sort) <(sort $PUBLIC_CONFIGS_PATH/pacmanfile))
	#curl -s https://api.github.com/repos/cerebroapp/cerebro/releases/latest | jq -e '.assets.[] | select(.browser_download_url | endswith(".dmg")).browser_download_url'
elif `is_ubuntu` ; then
	sudo add-apt-repository --yes ppa:mmstick76/alacritty
	xargs -r -a "$PUBLIC_CONFIGS_PATH/aptfile" sudo apt install --assume-yes
	assert_app_present curl
	echo "TODO: Install exa"
	echo "TODO: Install git-delta (https://dandavison.github.io/delta/installation.html)"

	if ! hash nvim 2>/dev/null; then
		title "Installing NeoVim"
		curl -L https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage -O /tmp/nvim.appimage
		chmod u+x /tmp/nvim.appimage
		sudo mv /tmp/nvim.appimage /usr/bin/nvim
	fi
fi


title "Setting symlinks"
link_item "Fonts directory" ~/.fonts "fonts"

if `is_linux` ; then
	link_item "i3wm configuration"                       ~/.config/i3/config                "dotfiles/i3-config"
	link_item "i3wm status-bar"                          ~/.config/i3/i3status.conf         "dotfiles/i3status-config"
	link_item "Custom status script for i3wm status-bar" ~/.config/i3/my-status.sh          "dotfiles/my-i3status-script.sh"
	link_item "Custom status script for i3wm status-bar" ~/.config/i3/my-status.py          "dotfiles/my-i3status-script.py"
	link_item "Custom lock-screen script for i3wm"       ~/.config/i3/my-lockscreen.sh      "tools/my-i3-lockscreen.sh"
	link_item "Custom lock-screen image for i3wm"        ~/.config/i3/lockscreen-center.png "pictures/lockscreen-center.png"
fi

link_item "tmux configuration"         ~/.config/tmux/config              "dotfiles/tmux.conf"
link_item "Git configuration"          ~/.gitconfig                       "dotfiles/gitconfig"
link_item "Git global ignore"          ~/.gitignore                       "dotfiles/gitignore"
link_item "Zsh configuration"          ~/.zshrc                           "dotfiles/zshrc"
link_item "Global shell configuration" ~/.profile                         "dotfiles/profile"
link_item "NPM configuration"          ~/.npmrc                           "dotfiles/npmrc"
link_item "NeoVim configuration"       ~/.config/nvim/init.vim            "dotfiles/init.vim"
link_item "Alacritty configuration"    ~/.config/alacritty/alacritty.toml "dotfiles/alacritty.toml"


if `is_work_machine` ; then
	source "$WORK_CONFIGS_PATH/setup/link_items.sh"
fi

if `is_osx` ; then
	title "Setting up Mac OS"

	list_item "Fixing scroll direction"
	defaults write -g com.apple.swipescrolldirection -bool FALSE

	list_item "Registering ITerm2 dotfile"
	defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$PUBLIC_CONFIGS_PATH/dotfiles"
	defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

	list_item "Generating Karabiner-Elements configuration"
	uv run "$PUBLIC_CONFIGS_PATH/tools/gen_karabiner_config.py" "$HOME/.config/karabiner/karabiner.json"
fi


echo ""
title "Setting up IDE"

echo -n " - " ; uv tool install "debugpy>=1.8.1,<2" --python 3.13 # For nvim DAP plugin (nvim-dap-python ; https://github.com/microsoft/debugpy)
echo -n " - " ; uv tool install --python 3.13 "pynvim"
echo -n " - " ; uv tool install --python 3.13 "python-lsp-server[rope]>=1.12.2" `# https://github.com/python-lsp/python-lsp-server` \
	--with "pylsp-rope>=0.1.17" `# https://github.com/python-rope/pylsp-rope` \
	--with "pylsp-mypy>=0.7.0" `# https://github.com/Richardk2n/pylsp-mypy` \
	--with "python-lsp-ruff>=2.2.2" `# https://github.com/python-lsp/python-lsp-ruff`
echo -n " - " ; uv tool install --python 3.13 "git+https://github.com/TalAmuyal/tmux-ggg"
rm -rf "$PUBLIC_CONFIGS_PATH/tools/*/build" "$PUBLIC_CONFIGS_PATH/tools/*/*.egg-info/"
if `is_personal_machine` ; then
	echo -n " - " ; ggg add --exist-ok "$WORKSPACE_DIR_PATH"
fi

echo -n " - " ; mise install node@lts

VIM_PLUG_LOCATION="$HOME/.local/share/nvim/site/autoload/plug.vim"
if [[ -f "$VIM_PLUG_LOCATION" ]]; then
	list_item "Vim Plug already installed"
else
	list_item "Installing vim-plug"
	curl -fLo "$VIM_PLUG_LOCATION" --create-dirs "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
fi
