
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
	if [[ -e $target_file_path ]] ; then
		rm -rf "$target_file_path"
	fi
	ln -s "$config_dir/$source_file_relative_path" "$target_file_path"
}
