#!/bin/bash

set -euo

# Sets up a fresh or existing OS install, including app installation and configuration
# Intended to be used on Ubuntu or Mac OS X
#
# Ansible was considered, but setting up Ansible for local setup is too much of a work and could be just done instead

echo "CWD: $PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "Script: $SCRIPT_DIR"

load() {
	NAME=$1
	source "$SCRIPT_DIR/setup/$NAME.sh"
}

execute() {
	NAME=$1
	shift
	bash "$SCRIPT_DIR/setup/$NAME.sh" "$@"
}

load variables
load prints
load detect_os

title "Making default directories"
execute \
	fix_each \
	"ls" \
	"mkdir -p" \
	"create" \
	~/.local/npm-global \
	~/dev \
	~/workspace \
	~/science
[ "$OS" == "X" ] && execute fix_each "ls" "mkdir -p" "create" ~/.config/karabiner
# Verify that at least one of the folders has been created
ls -l ~/science > /dev/null || exit 1


if [ "$OS" == "X" ] ; then
	[ "$TRAVIS" == "true" ] && yes | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)" ; ! hash brew > /dev/null 2>&1
	execute fix "hash brew" 'yes | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"' "Brew" "install"
fi


if [ "$OS" == "Ubuntu" ] ; then
	title "Updating packages cache"
	sudo apt update

	title "Upgrading installed packages"
	sudo apt upgrade --assume-yes
fi


if [ hash git 2>/dev/null ] ; then
	title "Git already installed"
else
	title "Installing Git"
	[ "$OS" == "X"      ] && brew install git
	[ "$OS" == "Ubuntu" ] && sudo apt install --assume-yes git
	[ ! hash git 2>/dev/null ] && echo "Failed to install Git" && exit 1
fi


if [ hash pyenv 2>/dev/null ] ; then
	title "Pyenv already installed"
else
	title "Installing Pyenv"
	git clone https://github.com/pyenv/pyenv.git ~/.pyenv
fi


echo "Done"
exit 0




title "Installing OS packages"
if [ "$OS" == "X" ] ; then
	brew tap homebrew/cask-fonts
	brew cask install font-fira-code
	brew cask install alacritty
	brew install watch git zsh tmux exa node yarn neovim
fi

if [ "$OS" == "Ubuntu" ] ; then
	sudo add-apt-repository -y ppa:mmstick76/alacritty
	sudo apt install --assume-yes xsel git zsh tmux scrot python3 i3 pinta pavucontrol curl blueman alacritty
	echo "TODO: Install exa (Using nix?)"

	if ! hash node 2>/dev/null; then
		title "Installing NodeJS"
		curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
		sudo apt install --assume-yes nodejs
	fi

	if ! hash nvim 2>/dev/null; then
		title "Installing NeoVim"
		curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
		chmod u+x nvim.appimage
		sudo mv nvim.appimage /usr/bin/nvim
	fi
fi





pyenv install $GLOBAL_PYTHON_VERSION

install_pipx() {
	title "Installing pipx"

	PIPX_ENV_DIR=~/.local/pipx_python_env
	mkdir -p $PIPX_ENV_DIR
	pushd $PIPX_ENV_DIR
	pyenv local $GLOBAL_PYTHON_VERSION
	python -m venv $PIPX_ENV_DIR/.venv
	bash -c "source .venv/bin/activate && python -m pip install pipx"
	popd
}
hash pipx 2>/dev/null || install_pipx()

title "Installing Python applications"
pipx install userpath

pipx install python-language-server
pipx inject python-language-server pyls-mypy

pipx install xonsh
pipx inject xonsh prompt-toolkit

pipx install pipenv
pipx install ptpython

title "Setting PATH"
userpath append ~/.local/bin
userpath append ~/.local/MyConfigs/aliases

title "Setting symlinks"
linkItem "Fonts directory"                            ~/.fonts                           "fonts"
if `isLinux` ; then
	linkItem "i3wm configuration"                         ~/.config/i3/config                "dotfiles/i3-config"
	linkItem "i3wm's status-bar"                          ~/.config/i3/i3status.conf         "dotfiles/i3status-config"
	linkItem "Custom status script for i3wm's status-bar" ~/.config/i3/my-status.sh          "dotfiles/my-i3status-script.sh"
	linkItem "Custom status script for i3wm's status-bar" ~/.config/i3/my-status.py          "dotfiles/my-i3status-script.py"
	linkItem "Custom lock-screen script for i3wm"         ~/.config/i3/my-lockscreen.sh      "scripts/my-i3-lockscreen.sh"
	linkItem "Custom lock-screen image for i3wm"          ~/.config/i3/lockscreen-center.png "pictures/lockscreen-center.png"
	#linkItem "Urxvt configuration"                        ~/.Xdefaults                       "dotfiles/Xdefaults"
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

if `isOsx` ; then
	defaults write -g com.apple.swipescrolldirection -bool FALSE
	defaults write com.extropy.oni ApplePressAndHoldEnabled -bool false
	defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$PWD/dotfiles"
	defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

	python3 "$PWD/scripts/gen_karabiner_config.py"
fi

title "Install vim-plug"
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

title "Install Vimspector"
mkdir -p $HOME/.config/nvim/pack

if `isLinux` ; then
	VIMSPECTOR_DIST="linux"
fi
if `isOsx` ; then
	VIMSPECTOR_DIST="macos"
fi
curl -L https://github.com/puremourning/vimspector/releases/download/262675652/vimspector-$VIMSPECTOR_DIST-262675652.tar.gz | tar -C $HOME/.config/nvim/pack zxvf -
