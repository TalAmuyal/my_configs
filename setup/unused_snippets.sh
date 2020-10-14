#dpkg -l pyenv
#brew list fswatch ; echo $?








# Prepare for Homebrew
MISSING_PACKAGES=""
if [ "$OS" == "Ubuntu" ] ; then
	dpkg -L build-essential > /dev/null 2>&1 ; [ $? -ne 0 ] && MISSING_PACKAGES="$MISSING_PACKAGES build-essential"
	dpkg -L zlib1g-dev      > /dev/null 2>&1 ; [ $? -ne 0 ] && MISSING_PACKAGES="$MISSING_PACKAGES zlib1g-dev"
	dpkg -L libffi-dev      > /dev/null 2>&1 ; [ $? -ne 0 ] && MISSING_PACKAGES="$MISSING_PACKAGES libffi-dev"
	[ ! -x "$(command -v curl)" ] && MISSING_PACKAGES="$MISSING_PACKAGES curl"
	[ ! -x "$(command -v git)"  ] && MISSING_PACKAGES="$MISSING_PACKAGES git"
	[ ! -z "$MISSING_PACKAGES" ] && [ `uname` == "Linux" ] && sudo apt update && sudo apt upgrade --assume-yes && sudo apt install --assume-yes $MISSING_PACKAGES
fi


# Install Homebrew
if ! -x "$(command -v brew)" ; then
	yes "" | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	[ -f $HOME/.linuxbrew/bin/brew ] && eval $($HOME/.linuxbrew/bin/brew shellenv)
	[ -f /home/linuxbrew/.linuxbrew/bin/brew ] && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi
[ ! -x "$(command -v brew)" ] && echo Failed to install or configure Homebrew && exit 1



# Install Homebrew recommended packages
[ ! -x "$(command -v gcc)" ] && brew install gcc


# Install Pyenv & Pyenv Virtualenv
#[ ! -x "$(command -v pyenv)" ] && PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
[ ! -x "$(command -v pyenv)" ] && brew install pyenv pyenv-virtualenv
[ ! -x "$(command -v pyenv)" ] && echo Failed to install or configure Pyenv && exit 1


# Install a new and stable Python
[ ! -x "$(command -v python$PYTHON_VERSION)" ] && pyenv install --skip-existing ${PYTHON_VERSION} && pyenv global ${PYTHON_VERSION} && pyenv rehash


# Install Pipx
if ! -x "$(command -v pipx)" ; then
	eval "$(pyenv init -)"
	eval "$(pyenv virtualenv-init -)"
	pushd /tmp && pyenv virtualenv $PYTHON_VERSION pipx_installation && popd
	pyenv activate pipx_installation
	python -m pip install --upgrade pip pipx
	pipx_exec=$(which pipx)
	[[ $pipx_exec == */shims/* ]] && rm -f $pipx_exec
	mkdir -p $HOME/.local/bin
	export PATH="$HOME/.local/bin:$PATH"
	cat >$HOME/.local/bin/pipx <<EOL
#!/bin/bash

export PYENV_VIRTUALENV_DISABLE_PROMPT=1
eval "\$(pyenv init -)"
eval "\$(pyenv virtualenv-init -)"
pyenv activate pipx_installation
python -m pipx \$@
EOL
	chmod +x $HOME/.local/bin/pipx
	source deactivate
fi
[ ! -x "$(command -v pipx)" ] && echo Failed to install or configure Pipx && exit 1


# Install Ansible
[ ! -x "$(command -v ansible-playbook)" ] && pipx install ansible --include-deps


# Run Ansible
cat >/tmp/ansible_hosts <<EOL
[local]
localhost

[local:vars]
ansible_connection=local
EOL

ansible-playbook -i /tmp/ansible_hosts $SCRIPT_DIR/ansible-playbook.yaml --ask-become-pass



exit

## Make sure that the native package manager is in place
#[ "$OS" == "X" ] && [ ! -x "$(command -v brew)" ] && ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"


## Make sure that the native package manager is up to date
#[ "$OS" == "Ubuntu" ] && [ ! -x "$(command -v pyenv)" ] && sudo apt update && sudo apt upgrade --assume-yes


## Get Pyenv
#[ "$OS" == "X"      ] && [ ! -x "$(command -v pyenv)" ] && brew install pyenv
#[ "$OS" == "Ubuntu" ] && [ ! -x "$(command -v pyenv)" ] && sudo apt install --assume-yes pyenv


sudo apt-get install git python-pip make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl
sudo pip install virtualenvwrapper

git clone https://github.com/yyuu/pyenv.git ~/.pyenv
git clone https://github.com/yyuu/pyenv-virtualenvwrapper.git ~/.pyenv/plugins/pyenv-virtualenvwrapper

bash
exit










if [ `uname` == "Linux" ] ; then
	sudo apt update
	sudo apt upgrade --assume-yes
	[ ! -x "$(command -v curl)" ] && sudo apt install --assume-yes curl
	[ ! -x "$(command -v xz)" ] && sudo apt install --assume-yes xz-utils
fi
[ ! -x "$(command -v nix)" ] && curl -L https://nixos.org/nix/install | sh && source /home/test_user/.nix-profile/etc/profile.d/nix.sh
[ ! -x "$(command -v nix)" ] && echo Failed to install Nix && exit 1
[ ! -x "$(command -v ansible)" ] && nix-env -i ansible
bash
exit

cat >/tmp/ansible_hosts <<EOL
[local]
localhost

[local:vars]
ansible_connection=local
EOL

# Get repo path
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


fiansible-playbook -i /tmp/ansible_hosts $SCRIPT_DIR/ansible-playbook.yaml --ask-become-pass

exit





title "Installing OS packages"
if `isOsx` ; then
	brew tap homebrew/cask-fonts
	brew cask install font-fira-code
	brew cask install alacritty
	brew install watch git zsh tmux pyenv exa node yarn neovim
fi

if `isLinux` ; then
	sudo add-apt-repository ppa:mmstick76/alacritty
	sudo apt install --assume-yes xsel git zsh tmux scrot python3 i3 pinta pavucontrol curl blueman alacritty
	echo "TODO: Install exa (Using nix?)"
	echo "TODO: Install pyenv"

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
