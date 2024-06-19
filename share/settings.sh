#!/data/data/com.termux/files/usr/bin/origami-sudo bash
# This file is part of Origami Kernel Manager.
#
# Origami Kernel Manager is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Origami Kernel Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Origami Kernel Manager.  If not, see <https://www.gnu.org/licenses/>.
#
# Copyright (C) 2023-2024 Rem01Gaming

execstoredcmd_switch() {
	case $(fzf_select "Enable Disable" "Apply previous settings from last session:  ") in
	Enable) execstoredcmd_db TRUE ;;
	Disable) execstoredcmd_db FALSE ;;
	esac
}

execstoredcmd_risky_switch() {
	case $(fzf_select "Enable Disable" "Allow risky execution:  ") in
	Enable) execstoredcmd_risky_db TRUE ;;
	Disable) execstoredcmd_risky_db FALSE ;;
	esac
}

settings_menu() {
	while true; do
		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $(($LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] Apply previous settings: $(sql_query "SELECT execstoredcmd FROM tb_info;")"
		echo -e "   /        /\\     [] Allow risky execution: $(sql_query "SELECT execstoredcmd_risky FROM tb_info;")"
		echo -e "  /        /  \\    "
		echo -e " /        /    \\   "
		echo -e "/________/      \\  "
		echo -e "\\        \\      /  "
		echo -e " \\        \\    /   "
		echo -e "  \\        \\  /    "
		echo -e "   \\________\\/     "
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "[] OKM Settings\033[0m"

		# Hide cursor
		tput civis

		case $(fzy_select "Apply previous settings\nAllow risky execution\nBack to main menu" "") in
		"Apply previous settings") execstoredcmd_switch ;;
		"Allow risky execution") execstoredcmd_risky_switch ;;
		"Back to main menu") break ;;
		esac
	done
}
