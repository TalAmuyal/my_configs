
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
