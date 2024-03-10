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

mtk_ged_dvfs() {
	case $(fzf_select "Enable Disable" "GPU DVFS:  ") in
	Enable) echo 1 >/sys/module/ged/parameters/gpu_dvfs_enable ;;
	Disable) echo 0 >/sys/module/ged/parameters/gpu_dvfs_enable ;;
	esac
}

mtk_ged_boost() {
	case $(fzf_select "Enable Disable" "GED Boosting: ") in
	Enable) echo 1 >/sys/module/ged/parameters/ged_boost_enable ;;
	Disable) echo 0 >/sys/module/ged/parameters/ged_boost_enable ;;
	esac
}

mtk_ged_extra_boost() {
	case $(fzf_select "Enable Disable" "GED Boost extra: ") in
	Enable) echo 1 >/sys/module/ged/parameters/boost_extra ;;
	Disable) echo 0 >/sys/module/ged/parameters/boost_extra ;;
	esac
}

mtk_ged_gpu_boost() {
	case $(fzf_select "Enable Disable" "GED GPU Boost: ") in
	Enable) echo 1 >/sys/module/ged/parameters/boost_gpu_enable ;;
	Disable) echo 0 >/sys/module/ged/parameters/boost_gpu_enable ;;
	esac
}

mtk_ged_game_mode() {
	case $(fzf_select "Enable Disable" "GED Game mode: ") in
	Enable) echo 1 >/sys/module/ged/parameters/gx_game_mode ;;
	Disable) echo 0 >/sys/module/ged/parameters/gx_game_mode ;;
	esac
}
