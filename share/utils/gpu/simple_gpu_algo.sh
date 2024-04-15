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

simple_gpu_switch() {
	case $(fzf_select "Disable Enable" "Simple GPU Algorithm: ") in
	Disable) echo 0 >/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate ;;
	Enable) echo 1 >/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate ;;
	esac
}

simple_gpu_laziness() {
	menu_value_tune "Simple GPU Laziness\nThis increases the threshold to ramp up or down GPU frequencies. The lower it is, the more performance you get." /sys/module/simple_gpu_algorithm/parameters/simple_laziness 10 0 1
}

simple_gpu_ramp_threshold() {
	menu_value_tune "Simple GPU Ramp threshold\nThis increases the number of times the GPU governor ramp down requests. The higher it is, the more performance you get." /sys/module/simple_gpu_algorithm/parameters/simple_ramp_threshold 10 0 1
}
