#!/data/data/com.termux/files/usr/bin/bash
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

mtk_dram_set_freq() {
	opp_selected="$(fzf_select_n "[OPP-1]: Enable DVFS\n$(cat $mtk_dram_opp_table_path | awk '{sub(/\n$/,""); printf("%s\\n", $0)}' | grep "^\[")" "Set frequency for DRAM (NO DVFS): ")"
	opp_num=$(echo "$opp_selected" | grep -o '\[[^]]*\]' | grep -oE '[+-]?[0-9]+')
	echo $opp_num >$mtk_dram_req_opp_path
}

mtk_dram_devfreq_set_freq() {
	echo $(fzf_select "$(cat ${mtk_dram_devfreq_path}/available_frequencies)" "Select ${1} freq: ") >${mtk_dram_devfreq_path}/${1}_freq
}

mtk_dram_devfreq_set_gov() {
	echo $(fzf_select "$(cat ${mtk_dram_devfreq_path}/available_governors)" "Select Governor: ") >${mtk_dram_devfreq_path}/governor
}

mtk_dram_menu() {
	while true; do
		if [ ! -z $mtk_dram_devfreq_path ]; then
			mtk_dram_menu_info="[] GPU Scalling freq: $(cat ${mtk_dram_devfreq_path}/max_freq) - $(cat ${mtk_dram_devfreq_path}/min_freq)//[] GPU Governor: $(cat ${mtk_dram_devfreq_path}/governor)//"
			mtk_dram_menu_options="Set max freq\nSet min freq\nSet Governor\n"
		elif [ ! -z $mtk_dram_path ] && [ ! -z $mtk_dram_opp_table_path ] && [ ! -z $mtk_dram_req_opp_path ]; then
			mtk_dram_menu_options="Set freq (NO DVFS)\n"
		else
			echo -e "\n[-] Interface (sysfs or procfs) of your DRAM is not supported"
			echo "[*] Hit enter to back to main menu"
			read -r -s
			clear && return 0
		fi

		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $((LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      $(echo "$mtk_dram_menu_info" | awk -F '//' '{print $1}')"
		echo -e "   /        /\\     $(echo "$mtk_dram_menu_info" | awk -F '//' '{print $2}')"
		echo -e "  /        /  \\    "
		echo -e ' /        /    \   '
		echo -e '/________/      \  '
		echo -e '\        \      /  '
		echo -e ' \        \    /   '
		echo -e '  \        \  /    '
		echo -e '   \________\/     '
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "[] DRAM Control\033[0m"

		tput civis

		case $(fzy_select "${mtk_dram_menu_options}Back to main menu" "") in
		"Set max freq") mtk_dram_devfreq_set_freq max ;;
		"Set min freq") mtk_dram_devfreq_set_freq min ;;
		"Set Governor") mtk_dram_devfreq_set_gov ;;
		"Set freq (NO DVFS)") mtk_dram_set_freq ;;
		"Back to main menu") clear && break ;;
		esac

		unset mtk_dram_menu_info mtk_dram_menu_options
	done
}
