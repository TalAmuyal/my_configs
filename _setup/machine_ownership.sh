
WORK_MACHINE_SENTINEL_PATH=~/.local/work_machine
PERSONAL_MACHINE_SENTINEL_PATH=~/.local/personal_machine


is_personal_machine() {
	[ -e "$PERSONAL_MACHINE_SENTINEL_PATH" ]
}


is_work_machine() {
	[ -e "$WORK_MACHINE_SENTINEL_PATH" ]
}


if ! `is_personal_machine` && ! `is_work_machine` ; then
	while true; do
		read -p "Is this a work machine? (yes/no): " yn
		case $yn in
			[Yy]* )
				title "Marking as work machine"
				touch "$WORK_MACHINE_SENTINEL_PATH"
				break
				;;
			[Nn]* )
				title "A personal machine"
				touch "$PERSONAL_MACHINE_SENTINEL_PATH"
				break
				;;
			* ) echo "Invalid input. Please answer yes or no.";;
		esac
	done
fi
