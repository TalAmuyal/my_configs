#!/bin/bash

set -euo pipefail # Stop on first error

echo "This script requires root permissions."
sudo echo "Thanks"

# Sets up a fresh OS install
# Intended to be used on Ubuntu, Arch, or Mac OS X

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PYTHON_VENVS=~/.local/python_venvs  # TODO: Rename to "python_virtual_envs" and update init.vim (and maybe other files too)
ASDF_VM_DIR=~/.local/asdf


is_osx() {
	[ `uname` == "Darwin" ]
}

is_arch() {
	[ -f "/etc/arch-release" ]
}

is_ubuntu() {
	[ -f "/etc/os-release" ] && grep -qi "ubuntu" /etc/os-release
}

is_linux() {
	[ `uname` == "Linux" ]
}

title() {
	echo
	echo "~~~ $1 ~~~"
}

list_item() {
	echo " - $1"
}

link_item() {
	local description="$1"
	local target_file_path="$2"
	local target_parent_dir="$(dirname "$target_file_path")"
	local source_file_relative_path="$3"

	list_item "$description"

	mkdir -p "$target_parent_dir"
	if [[ -L $target_file_path ]] ; then
		rm -rf "$target_file_path"
	fi
	ln -s "$SCRIPT_DIR/$source_file_relative_path" "$target_file_path"
}


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

prompt_yes_no() {
	local prompt="$1"
	local response

	read -p "$prompt (y/n): " response
	if [[ "$response" =~ ^[Yy]$ ]]; then
		return 0
	elif [[ "$response" =~ ^[Nn]$ ]]; then
		return 1
	else
		prompt_yes_no "$prompt"
		return $?
	fi
}

title "Making default dirs"
DEFAULT_DIRS=( "~/dev" "~/workspace" "~/science" "$PYTHON_VENVS" )
for i in "${DEFAULT_DIRS[@]}"
do
	:
		echo -n " - \"$i\" "
		[ -d "$i" ] && echo "already exists" || (mkdir -p "$i" ; ([ -d "$i" ] && echo "created" || (echo "failed to create")))
done


if `is_osx` ; then
	if ! hash brew 2>/dev/null; then
		title "Installing Homebrew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	fi
fi

if `is_ubuntu` ; then
	title "Updating packages cache"
	sudo apt update

	title "Upgrading installed packages"
	sudo apt upgrade --assume-yes
fi

title "Installing OS packages"
if `is_osx` ; then
	brew bundle install --file=$SCRIPT_DIR/brewfile
elif `is_arch`; then
	sudo pacman --noconfirm -S --needed $(comm -12 <(pacman -Slq | sort) <(sort $SCRIPT_DIR/pacmanfile))
	#curl -s https://api.github.com/repos/cerebroapp/cerebro/releases/latest | jq -e '.assets.[] | select(.browser_download_url | endswith(".dmg")).browser_download_url'
elif `is_ubuntu` ; then
	# TODO: Make an ubuntu-compat version of a brewfile
	#if ! hash curl 2>/dev/null; then
	#	if `is_ubuntu` ; then
	#		sudo apt install --assume-yes curl
	#	fi
	#fi
	#assert_app_present curl
	sudo add-apt-repository --yes ppa:mmstick76/alacritty
	sudo apt install --assume-yes xsel git zsh tmux scrot python3 i3 pinta pavucontrol curl blueman alacritty
	echo "TODO: Install exa (Using nix?)"

	echo "TODO: Install git-delta (https://dandavison.github.io/delta/installation.html)"

	if ! hash nvim 2>/dev/null; then
		title "Installing NeoVim"
		curl -L https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage -O /tmp/nvim.appimage
		chmod u+x /tmp/nvim.appimage
		sudo mv /tmp/nvim.appimage /usr/bin/nvim
	fi
fi

[ ! -e "$ASDF_VM_DIR" ] && \
	title "Installing ASDF-VM"  && \
	git clone https://github.com/asdf-vm/asdf.git "$ASDF_VM_DIR" --branch v0.12.0
source $ASDF_VM_DIR/asdf.sh
ASDF_INSTALLS_DIR=$ASDF_VM_DIR/installs

[ ! -e "$ASDF_INSTALLS_DIR/python" ] && \
	title "Installing Python using ASDF-VM" && \
	asdf plugin add python && \
	asdf install python latest:3.10  && \
	asdf global python latest:3.10

[ ! -e "$ASDF_INSTALLS_DIR/nodejs" ] && \
	title "Installing NodeJS using ASDF-VM" && \
	asdf plugin add nodejs && \
	asdf install nodejs latest:16 && \
	asdf global nodejs latest:16

PYLSP_PYTHON_VENV=$PYTHON_VENVS/pylsp
[ ! -e "$PYLSP_PYTHON_VENV" ] && \
	title "Installing Python LSP" && \
	(python -m venv "$PYLSP_PYTHON_VENV" && $PYLSP_PYTHON_VENV/bin/python -m pip install -U pip python-language-server[all] pylint pylsp-mypy pyls-isort)

DEBUGPY_PYTHON_VENV=$PYTHON_VENVS/debugpy
[ ! -e "$DEBUGPY_PYTHON_VENV" ] && \
	title "Installing DebugPy" && \
	(python -m venv "$DEBUGPY_PYTHON_VENV" && $DEBUGPY_PYTHON_VENV/bin/python -m pip install -U pip debugpy) # For nvim DAP plugin (nvim-dap-python)

NVIM_PYTHON_VENV=$PYTHON_VENVS/pynvim
[ ! -e "$NVIM_PYTHON_VENV" ] && \
	title "Installing Neovim Python (venv)" && \
	python -m venv $NVIM_PYTHON_VENV && \
	$NVIM_PYTHON_VENV/bin/python -m pip install -U pip pynvim


if `is_osx` ; then
	title "Cloning work repository"
	WORK_CONFIGS_PATH=~/.local/work_configs
	[ -d $WORK_CONFIGS_PATH ] && echo "Already cloned." || (git clone github.com/TalAmuyal/work_configs $WORK_CONFIGS_PATH)
fi


title "Setting symlinks"
link_item "Fonts directory"                            ~/.fonts                           "fonts"
if `is_linux` ; then
	link_item "i3wm configuration"                         ~/.config/i3/config                "dotfiles/i3-config"
	link_item "i3wm's status-bar"                          ~/.config/i3/i3status.conf         "dotfiles/i3status-config"
	link_item "Custom status script for i3wm's status-bar" ~/.config/i3/my-status.sh          "dotfiles/my-i3status-script.sh"
	link_item "Custom status script for i3wm's status-bar" ~/.config/i3/my-status.py          "dotfiles/my-i3status-script.py"
	link_item "Custom lock-screen script for i3wm"         ~/.config/i3/my-lockscreen.sh      "scripts/my-i3-lockscreen.sh"
	link_item "Custom lock-screen image for i3wm"          ~/.config/i3/lockscreen-center.png "pictures/lockscreen-center.png"
fi

link_item "tmux configuration"                         ~/.config/tmux/config              "dotfiles/tmux.conf"
link_item "Git configuration (1/3)"                    ~/.gitconfig                       "dotfiles/gitconfig"
link_item "Git configuration (2/3)"                    ~/.gitignore                       "dotfiles/gitignore"
link_item "Git configuration (3/3)"                    ~/dev/.gitconfig                   "dotfiles/work-gitconfig"
link_item "Zsh configuration"                          ~/.zshrc                           "dotfiles/zshrc"
link_item "Global shell configuration"                 ~/.profile                         "dotfiles/profile"
link_item "Xonsh configuration"                        ~/.xonshrc                         "dotfiles/xonshrc"
link_item "NPM configuration"                          ~/.npmrc                           "dotfiles/npmrc"
link_item "NeoVim configuration"                       ~/.config/nvim/init.vim            "dotfiles/init.vim"
link_item "Alacritty configuration"                    ~/.config/alacritty/alacritty.yml  "dotfiles/alacritty.yml"
link_item "Kitty configuration"                        ~/.config/kitty/kitty.conf         "dotfiles/kitty.conf"

if `is_osx` ; then
	defaults write -g com.apple.swipescrolldirection -bool FALSE
	defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$PWD/dotfiles"
	defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

	python3 "$PWD/scripts/gen_karabiner_config.py"
fi

title "Install vim-plug"
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
