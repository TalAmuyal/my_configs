#!/bin/bash

set -euo pipefail # Stop on first error

echo "This script requires root permissions."
sudo echo "Thanks"

# Sets up a fresh OS install
# Intended to be used on Ubuntu, Arch, or Mac OS X

PUBLIC_CONFIGS_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PRIVATE_CONFIGS_PATH=~/.local/work_configs
PYTHON_VENVS=~/.local/python_venvs
ASDF_VM_DIR=~/.local/asdf

PYTHON_GLOBAL_VERSION=3.12


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
	local config_dir="${4:-$PUBLIC_CONFIGS_PATH}"

	list_item "$description"

	mkdir -p "$target_parent_dir"
	if [[ -L $target_file_path ]] ; then
		rm -rf "$target_file_path"
	fi
	ln -s "$config_dir/$source_file_relative_path" "$target_file_path"
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

install_pypi_python_tool() {
	local tool_name="$1"
	local tool_requirements_txt_path="$PUBLIC_CONFIGS_PATH/python_env_configs/$tool_name/requirements.txt"
	local tool_env_dir="$PYTHON_VENVS/$tool_name"
	local tool_env_python="$tool_env_dir/bin/python"

	[ -e "$tool_env_dir" ] && return 0

	title "Installing $tool_name" && \
		python -m venv "$tool_env_dir" && \
		"$tool_env_python" -m pip install -U pip && \
		"$tool_env_python" -m pip install -r "$tool_requirements_txt_path"
}

install_local_python_tool() {
	local tool_name="$1"
	local source_repo="$2"
	if [ "$source_repo" != "private" ] && [ "$source_repo" != "public" ]; then
		echo "Invalid source repo: $source_repo"
		exit 1
	fi
	local repo_path=$([ "$source_repo" == "public" ] && echo "$PUBLIC_CONFIGS_PATH" || echo "$PRIVATE_CONFIGS_PATH")
	local tool_main_script="$repo_path/python_env_configs/$tool_name/main.py"
	local tool_requirements_txt_path="$repo_path/python_env_configs/$tool_name/requirements.txt"
	local tool_env_dir="$PYTHON_VENVS/$tool_name"
	local tool_env_python="$tool_env_dir/bin/python"
	local executable_path=$HOME/.local/bin/$tool_name

	[ -e "$tool_env_dir" ] && return 0

	title "Installing $tool_name" && \
		python -m venv "$tool_env_dir" && \
		"$tool_env_python" -m pip install -U pip
	[ -e "$tool_requirements_txt_path" ] && "$tool_env_python" -m pip install -r "$tool_requirements_txt_path"

	[ ! -e "$executable_path" ] && \
		echo "#!/bin/bash" > "$executable_path" && \
		echo "$tool_env_python $tool_main_script \"\$@\"" >> "$executable_path" && \
		chmod +x "$executable_path"
}

# create known_hosts and ssh config with proper permissions if missing
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


title "Cloning private configs repository"
[ -d $PRIVATE_CONFIGS_PATH ] && \
	echo "Already cloned." || \
	(git clone git@github.com:TalAmuyal/work_configs.git $PRIVATE_CONFIGS_PATH)

source "$PRIVATE_CONFIGS_PATH/setup/is_work_machine.sh"


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
	brew bundle install "--file=$PUBLIC_CONFIGS_PATH/brewfile"
elif `is_arch`; then
	sudo pacman --noconfirm -S --needed $(comm -12 <(pacman -Slq | sort) <(sort $PUBLIC_CONFIGS_PATH/pacmanfile))
	#curl -s https://api.github.com/repos/cerebroapp/cerebro/releases/latest | jq -e '.assets.[] | select(.browser_download_url | endswith(".dmg")).browser_download_url'
elif `is_ubuntu` ; then
	sudo add-apt-repository --yes ppa:mmstick76/alacritty
	xargs -r -a "$PRIVATE_CONFIGS_PATH/aptfile" sudo apt install --assume-yes
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

[ ! -e "$ASDF_VM_DIR" ] && \
	title "Installing ASDF-VM"  && \
	git clone https://github.com/asdf-vm/asdf.git "$ASDF_VM_DIR" --branch v0.12.0
source $ASDF_VM_DIR/asdf.sh
ASDF_INSTALLS_DIR=~/.asdf/installs

[ ! -e "$ASDF_INSTALLS_DIR/python" ] && \
	title "Installing Python using ASDF-VM" && \
	asdf plugin add python && \
	asdf install python "latest:$PYTHON_GLOBAL_VERSION"  && \
	asdf global python "latest:$PYTHON_GLOBAL_VERSION"

[ ! -e "$ASDF_INSTALLS_DIR/nodejs" ] && \
	title "Installing NodeJS using ASDF-VM" && \
	asdf plugin add nodejs && \
	asdf install nodejs latest:18 && \
	asdf global nodejs latest:18

install_pypi_python_tool "pylsp"
install_pypi_python_tool "debugpy"
install_pypi_python_tool "pynvim"

install_local_python_tool "ggg" "private"


title "Setting symlinks"
link_item "Fonts directory" ~/.fonts "fonts"

if `is_linux` ; then
	link_item "i3wm configuration"                       ~/.config/i3/config                "dotfiles/i3-config"
	link_item "i3wm status-bar"                          ~/.config/i3/i3status.conf         "dotfiles/i3status-config"
	link_item "Custom status script for i3wm status-bar" ~/.config/i3/my-status.sh          "dotfiles/my-i3status-script.sh"
	link_item "Custom status script for i3wm status-bar" ~/.config/i3/my-status.py          "dotfiles/my-i3status-script.py"
	link_item "Custom lock-screen script for i3wm"       ~/.config/i3/my-lockscreen.sh      "scripts/my-i3-lockscreen.sh"
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

source "$PRIVATE_CONFIGS_PATH/setup/link_items.sh"

if `is_osx` ; then
	defaults write -g com.apple.swipescrolldirection -bool FALSE
	defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$PWD/dotfiles"
	defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

	python "$PWD/scripts/gen_karabiner_config.py"
	link_item "Karabiner-Elements configuration" ~/.config/karabiner/karabiner.json "dotfiles/karabiner.json"
fi

title "Install vim-plug"
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
