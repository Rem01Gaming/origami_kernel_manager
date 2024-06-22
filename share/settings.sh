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
	# Easter Egg #1
	# Kanged from Namida app, hehe
	easteregg() {
		dialog1() {
			clear
			tput civis
			echo -e "\na- ano...\n\nthis one is actually supposed to be for supporters, if you don't mind you can support Origami Kernel Manager and get the power to unleash this cool feature\nor you just wanna use it like that? mattaku" | fold -s -w ${LINE}
			local selected=$(fzy_select "Support\nLeave it disabled\nUmm..." "")
			case $selected in
			Support) donate && easteregg_output="TRUE" ;;
			"Leave it disabled") easteregg_output="FALSE" ;;
			"Umm...") dialog2 ;;
			esac
		}

		dialog2() {
			clear
			tput civis
			echo -e "\nEH? YOU DON'T WANT TO SUPPORT?" | fold -s -w ${LINE}
			local selected=$(fzy_select "Yes\nNo" "")
			case $selected in
			Yes) donate && easteregg_output="TRUE" ;;
			No) dialog3 ;;
			esac
		}

		dialog3() {
			clear
			tput civis
			echo -e "\nhidoii ಥ⁠‿⁠ಥ here use it as u can,\ndw im not upset or anything ^^, or am i?" | fold -s -w ${LINE}
			local selected=$(fzy_select "UNLOCK\nSUPPORT" "")
			case $selected in
			SUPPORT) donate && easteregg_output="TRUE" ;;
			UNLOCK) easteregg_output="TRUE" ;;
			esac
		}

		dialog1
	}

	case $(fzf_select "Enable Disable" "Apply previous settings from last session:  ") in
	Enable) easteregg && execstoredcmd_db $easteregg_output ;;
	Disable) execstoredcmd_db FALSE ;;
	esac

	unset easteregg_output
}

execstoredcmd_risky_switch() {
	if [ $(sql_query "SELECT execstoredcmd FROM tb_info;") -eq 0 ]; then
		echo -e "\n[-] Enable Apply previous settings feature first"
		echo "[*] Hit enter to back to main menu"
		read -r -s
		return 1
	fi

	case $(fzf_select "Enable Disable" "Allow risky execution:  ") in
	Enable) execstoredcmd_risky_db TRUE ;;
	Disable) execstoredcmd_risky_db FALSE ;;
	esac
}

clear_storedcmd() {
	clear
	tput civis
	echo -e "\nClear stored settings on database?\n\nThis will clear all stored commands for Apply previous settings feature and Battery utils. only clear it if you find some weird behavior that you don't wanted." | fold -s -w ${LINE}
	local selected=$(fzy_select "Proceed\nAbort" "")
	case $selected in
	Proceed)
		sql_query "DELETE FROM tb_storecmd;"
		sql_query "DELETE FROM tb_idlechg;"
		;;
	Abort) ;;
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

		case $(fzy_select "Apply previous settings\nAllow risky execution\nClear stored settings on database\nBack to main menu" "") in
		"Apply previous settings") execstoredcmd_switch ;;
		"Allow risky execution") execstoredcmd_risky_switch ;;
		"Clear stored settings on database") clear_storedcmd ;;
		"Back to main menu") break ;;
		esac
	done
}
