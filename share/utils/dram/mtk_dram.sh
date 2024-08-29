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
	if [[ $1 == "-exec" ]]; then
		local opp_num=$2
	else
		local opp_table="[OPP-1]: Enable DVFS\n$(cat $mtk_dram_opp_table_path | awk '{sub(/\n$/,""); printf("%s\\n", $0)}' | grep "^\[")"
		local opp_selected="$(fzf_select_n "${opp_table%\\n}" "Set frequency for DRAM (NO DVFS): ")"
		local opp_num=$(echo "$opp_selected" | grep -o '\[[^]]*\]' | grep -oE '[+-]?[0-9]+')
		command2db dram.mtk.freq_lock "mtk_dram_set_freq -exec $opp_num" FALSE
	fi
	apply $opp_num $mtk_dram_req_opp_path
}

mtk_dram_menu() {
	while true; do
		unset_headvar
		header "DRAM Control"
		selected="$(fzy_select "Set freq (NO DVFS)\nBack to main menu" "")"

		case "$selected" in
		"Set freq (NO DVFS)") mtk_dram_set_freq ;;
		"Back to main menu") break ;;
		esac
	done
}
