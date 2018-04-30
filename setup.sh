#!/bin/bash

# Sets up the environment as if after a fresh install
# Intended to use on Ubuntu 17.04+ or Mac OS X High Sierra

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
	if [[ ! -e $2 ]] ; then
		listItem "$1"
		linkDir=$(dirname $2)
		mkdir -p "$linkDir"
		ln -s $(pwd)/$3 $2
	fi
}

mkdir -p ~/.local/npm-global

if `isOsx` ; then
	title "Install Hoebrew"
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	export PATH=/usr/local/bin:/usr/local/sbin:$PATH
else
	title "Updating packages cache"
	sudo apt update

	title "Upgrading installed packages"
	sudo apt upgrade --assume-yes
fi

title "Installing OS packages"
if `isOsx` ; then
	brew install python3 node yarn tmux neovim
else
	sudo apt install --assume-yes git zsh tmux scrot python3 i3 pinta pavucontrol curl rxvt-unicode blueman

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

title "Installing Python packages"
pip install -U python-language-server pyls-mypy

title "Setting symlinks"
linkItem "Fonts directory"                            ~/.fonts                           "fonts"
if `isLinux` ; then
	linkItem "i3wm configuration"                         ~/.config/i3/config                "dotfiles/i3-config"
	linkItem "i3wm's status-bar"                          ~/.config/i3/i3status.conf         "dotfiles/i3status-config"
	linkItem "Custom status script for i3wm's status-bar" ~/.config/i3/my-status.sh          "dotfiles/my-i3status-script.sh"
	linkItem "Custom status script for i3wm's status-bar" ~/.config/i3/my-status.py          "dotfiles/my-i3status-script.py"
	linkItem "Custom lock-screen script for i3wm"         ~/.config/i3/my-lockscreen.sh      "scripts/my-i3-lockscreen.sh"
	linkItem "Custom lock-screen image for i3wm"          ~/.config/i3/lockscreen-center.png "pictures/lockscreen-center.png"
	linkItem "Urxvt configuration"                        ~/.Xdefaults                       "dotfiles/Xdefaults"
fi
linkItem "tmux configuration"                         ~/.config/tmux/config              "dotfiles/tmux.conf"
#linkItem "Hyper.app configuration"                    ~/.hyper.js                        "dotfiles/hyper.js"
linkItem "Git configuration"                          ~/.gitconfig                       "dotfiles/gitconfig"
linkItem "Zsh configuration"                          ~/.zshrc                           "dotfiles/zshrc"
linkItem "NPM configuration"                          ~/.npmrc                           "dotfiles/npmrc"
linkItem "Oni configuration"                          ~/.oni/config.js                   "dotfiles/oni-config.js"
linkItem "NeoVim configuration"                       ~/.config/nvim/init.vim            "dotfiles/init.vim"

if `isOsx` ; then
	defaults write -g com.apple.swipescrolldirection -bool FALSE
	defaults write com.extropy.oni ApplePressAndHoldEnabled -bool false
fi
