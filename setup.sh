#!/bin/bash

# Sets up a fresh OS install
# Intended to be used on Ubuntu 17.04+ or Mac OS X Mojave

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

	if [[ -e $2 ]] ; then
		rm -rf "$2"
	fi

	linkDir=$(dirname $2)
	mkdir -p "$linkDir"
	ln -s $(pwd)/$3 $2
}

title "Making default dirs"
mkdir -p ~/.local/npm-global ~/dev ~/workspace ~/science

if `isOsx` ; then
	mkdir -p ~/.config/karabiner
fi

if `isOsx` ; then
	if ! hash brew 2>/dev/null; then
		title "Installing Homebrew"
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
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
	brew tap homebrew/cask-fonts
	brew cask install font-fira-code
	brew cask install alacritty
	brew install watch git zsh tmux pyenv pipx exa node yarn neovim
fi

if `isLinux` ; then
	sudo add-apt-repository ppa:mmstick76/alacritty
	sudo apt install --assume-yes xsel git zsh tmux scrot python3 i3 pinta pavucontrol curl blueman alacritty
	echo "TODO: Install exa (Using nix?)"
	echo "TODO: Install pyenv"
	echo "TODO: Install pipx"

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

pyenv install 3.8.0

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
linkItem "Xonsh configuration"                        ~/.xonshrc                         "dotfiles/xonshrc"
linkItem "NPM configuration"                          ~/.npmrc                           "dotfiles/npmrc"
linkItem "Oni configuration"                          ~/.oni/config.js                   "dotfiles/oni-config.js"
linkItem "NeoVim configuration"                       ~/.config/nvim/init.vim            "dotfiles/init.vim"
linkItem "Alacritty configuration"                    ~/.config/alacritty/alacritty.yml  "dotfiles/alacritty.yml"

if `isOsx` ; then
	defaults write -g com.apple.swipescrolldirection -bool FALSE
	defaults write com.extropy.oni ApplePressAndHoldEnabled -bool false
	defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$HOME/.local/MyConfigs/dotfiles"
	defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

	python3 "$HOME/.local/MyConfigs/scripts/gen_karabiner_config.py"
fi

title "Install vim-plug"
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
