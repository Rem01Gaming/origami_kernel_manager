#!/bin/env bash
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
# Copyright (C) 2023-present Rem01Gaming

execstoredcmd_switch() {
	# Easter Egg #1
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

clear_db() {
	clear
	tput civis
	echo -e "\nClear database?\n\nThis will remove previous database including any data and create new fresh database. only proceed it if you find some weird behavior that you don't wanted." | fold -s -w ${LINE}
	local selected=$(fzy_select "Proceed\nAbort" "")
	case $selected in
	Proceed)
		remove_database
		create_database
		accept_risk
		;;
	Abort) ;;
	esac
}

settings_menu() {
	while true; do
		unset_headvar
		header_info=(
			"[] Apply previous settings: $(sql_query "SELECT execstoredcmd FROM tb_info;")"
			"[] Allow risky execution: $(sql_query "SELECT execstoredcmd_risky FROM tb_info;")"
		)

		header "OKM Settings"

		case $(fzy_select "Apply previous settings\nAllow risky execution\nClear database\nBack to main menu" "") in
		"Apply previous settings") execstoredcmd_switch ;;
		"Allow risky execution") execstoredcmd_risky_switch ;;
		"Clear database") clear_db ;;
		"Back to main menu") break ;;
		esac
	done
}
