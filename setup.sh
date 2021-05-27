#!/bin/bash

set -euo pipefail # Stop on first error

# Sets up a fresh OS install
# Intended to be used on Ubuntu 17.04+ or Mac OS X Mojave

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PYTHON_VENVS=$HOME/.local/python_venvs  # TODO: Rename to "python_virtual_envs" and update init.vim (and maybe other files too)
ASDF_VM_DIR=$HOME/.local/asdf

isOsx() {
	[ `uname` == "Darwin" ]
}

isLinux() {
	[ `uname` == "Linux" ]
}

title() {
	echo
	echo "~~~ $1 ~~~"
}

listItem() {
	echo " - $1"
}

linkItem() {
	listItem "$1"

	if [[ -L $2 ]] ; then
		rm -rf "$2"
	fi

	linkDir=$(dirname $2)
	mkdir -p "$linkDir"
	ln -s "$SCRIPT_DIR/$3" "$2"
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

title "Cloning work repository"
WORK_CONFIGS_PATH=~/.local/work_configs
[ -d $WORK_CONFIGS_PATH ] && echo "Already cloned." || (git clone github.com/TalAmuyal/work_configs $WORK_CONFIGS_PATH)

title "Making default dirs"
DEFAULT_DIRS=( "~/dev" "~/workspace" "~/science" "$PYTHON_VENVS" )
if `isOsx` ; then
	DEFAULT_DIRS+=('~/.config/karabiner')
fi

for i in "${DEFAULT_DIRS[@]}"
do
	:
		echo -n " - \"$i\" "
		[ -d "$i" ] && echo "already exists" || (mkdir -p "$i" ; ([ -d "$i" ] && echo "created" || (echo "failed to create")))
done


if `isOsx` ; then
	if ! hash brew 2>/dev/null; then
		title "Installing Homebrew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	fi
fi

if `isLinux` ; then
	title "Updating packages cache"
	sudo apt update

	title "Upgrading installed packages"
	sudo apt upgrade --assume-yes
fi

title "Installing OS packages"
if `isOsx` ; then
	brew bundle install --file=$SCRIPT_DIR/brewfile
fi

if `isLinux` ; then
	# TODO: Move the a linux-compat version of a brewfile
	#if ! hash curl 2>/dev/null; then
	#	if `isLinux` ; then
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
	git clone https://github.com/asdf-vm/asdf.git "$ASDF_VM_DIR"
source $ASDF_VM_DIR/asdf.sh
ASDF_INSTALLS_DIR=$HOME/.asdf/installs

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
	(python -m venv "$PYLSP_PYTHON_VENV" && $PYLSP_PYTHON_VENV/bin/python -m pip install python-language-server[all] pylint pylsp-mypy pyls-isort)

DEBUGPY_PYTHON_VENV=$PYTHON_VENVS/debugpy
[ ! -e "$DEBUGPY_PYTHON_ENV" ] && \
	title "Installing DebugPy" && \
	(python -m venv "$DEBUGPY_PYTHON_VENV" && $DEBUGPY_PYTHON_VENV/bin/python -m pip install debugpy) # For nvim DAP plugin (nvim-dap-python)

NVIM_PYTHON_VENV=$PYTHON_VENVS/pynvim
[ ! -e "$NVIM_PYTHON_VENV" ] && \
	title "Installing Neovim Python (venv)" && \
	python -m venv $NVIM_PYTHON_VENV && \
	$NVIM_PYTHON_VENV/bin/python -m pip install pynvim

title "Setting symlinks"
linkItem "Fonts directory"                            ~/.fonts                           "fonts"
if `isLinux` ; then
	linkItem "i3wm configuration"                         ~/.config/i3/config                "dotfiles/i3-config"
	linkItem "i3wm's status-bar"                          ~/.config/i3/i3status.conf         "dotfiles/i3status-config"
	linkItem "Custom status script for i3wm's status-bar" ~/.config/i3/my-status.sh          "dotfiles/my-i3status-script.sh"
	linkItem "Custom status script for i3wm's status-bar" ~/.config/i3/my-status.py          "dotfiles/my-i3status-script.py"
	linkItem "Custom lock-screen script for i3wm"         ~/.config/i3/my-lockscreen.sh      "scripts/my-i3-lockscreen.sh"
	linkItem "Custom lock-screen image for i3wm"          ~/.config/i3/lockscreen-center.png "pictures/lockscreen-center.png"
fi

linkItem "tmux configuration"                         ~/.config/tmux/config              "dotfiles/tmux.conf"
linkItem "Git configuration (1/3)"                    ~/.gitconfig                       "dotfiles/gitconfig"
linkItem "Git configuration (2/3)"                    ~/.gitignore                       "dotfiles/gitignore"
linkItem "Git configuration (3/3)"                    ~/dev/.gitconfig                   "dotfiles/work-gitconfig"
linkItem "Zsh configuration"                          ~/.zshrc                           "dotfiles/zshrc"
linkItem "Global shell configuration"                 ~/.profile                         "dotfiles/profile"
linkItem "Xonsh configuration"                        ~/.xonshrc                         "dotfiles/xonshrc"
linkItem "NPM configuration"                          ~/.npmrc                           "dotfiles/npmrc"
linkItem "Oni configuration"                          ~/.oni/config.js                   "dotfiles/oni-config.js"
linkItem "NeoVim configuration"                       ~/.config/nvim/init.vim            "dotfiles/init.vim"
linkItem "Alacritty configuration"                    ~/.config/alacritty/alacritty.yml  "dotfiles/alacritty.yml"
linkItem "Kitty configuration"                        ~/.config/kitty/kitty.conf         "dotfiles/kitty.conf"

if `isOsx` ; then
	defaults write -g com.apple.swipescrolldirection -bool FALSE
	defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$PWD/dotfiles"
	defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

	python3 "$PWD/scripts/gen_karabiner_config.py"
fi

title "Install vim-plug"
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
