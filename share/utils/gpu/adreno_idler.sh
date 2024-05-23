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
# You should have received a copy o f the GNU General Public License
# along with Origami Kernel Manager.  If not, see <https://www.gnu.org/licenses/>.
#
# Copyright (C) 2023-2024 Rem01Gaming

adreno_idler_switch() {
	case $(fzf_select "Disable Enable" "Simple GPU Algorithm: ") in
	Disable) apply N /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate ;;
	Enable) apply Y /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate ;;
	esac
}

adreno_idler_wait() {
	menu_value_tune "Adreno Ilde Wait\nNumber of events to wait before ramping down the frequency, Adreno idler will more actively try to ramp down the frequency if this is set to a lower value." /sys/module/adreno_idler/parameters/adreno_idler_idlewait 99 0 1
}

adreno_idler_down_diferential() {
	menu_value_tune "Adreno Idler Down Diferential" /sys/module/adreno_idler/parameters/adreno_idler_downdifferential 99 0 1
}

adreno_idler_workload() {
	menu_value_tune "Adreno Idler Workload\nThreshold for determining if the given workload is idle, Adreno idler will more actively try to ramp down the frequency if this is set to a higher value." /sys/module/adreno_idler/parameters/adreno_idler_idleworkload 10000 1000 10
}
