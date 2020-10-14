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
