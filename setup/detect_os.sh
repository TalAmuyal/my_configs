OS=""
[ `uname` == "Darwin" ]                               && OS="X"
[ `uname` == "Linux"  ] && [ -x "$(command -v apt)" ] && OS="Ubuntu"
[ -z "$OS" ] && echo "Unrecognized OS, aborting..." && exit 1
echo "OS Detected: $OS"
