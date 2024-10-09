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

[ -z $PREFIX ] && PREFIX="/usr"

version_code() {
	echo $1 | tr -cd '0-9'
}

okm_show_usage() {
	VERSION="$(cat $PREFIX/share/origami-kernel/version)"
	cat <<EOF
OKM - Origami Kernel Manager $VERSION
  Usage: okm
  Usage: okm [option]
  
  Options:
    update  Check for latest version and update OKM
    help    Show this message
EOF
}

okm_update() {
	source $PREFIX/share/origami-kernel/menu_helper.sh

	update_dir="$TMPDIR/.origami_kernel_manager"
	update_deb="$TMPDIR/.origami-kernel.deb"

	trap "stop_throbber && tput cnorm" EXIT
	tput civis
	VERSION="$(cat $PREFIX/share/origami-kernel/version)"

	# Check dependencies
	if ! hash curl; then
		echo "error: Environment has missing dependencies"
		exit 127
	fi

	start_throbber "Checking for new update..."

	if [[ $(apt list) == *origami-kernel* ]]; then
		install_deb=1
	fi >/dev/null 2>&1

	repo_info=$(curl -s "https://api.github.com/repos/rem01gaming/origami_kernel_manager/releases/latest")
	curl_exit=$?
	stop_throbber
	if [ $curl_exit -gt 0 ]; then
		echo "error: Can't fetch repository info from GitHub API, check your Internet connection!"
		exit 0
	fi

	latest_release=$(echo $repo_info | jq -r ".tag_name")

	if [ "$(version_code $VERSION)" -eq "$(version_code $latest_release)" ]; then
		echo "Current version is Up-to-date :)"
		exit 0
	elif [ "$(version_code $VERSION)" -gt "$(version_code $latest_release)" ]; then
		echo "error: Current installed version is greater than release version, you came from future?"
		exit 0
	elif [ "$(version_code $VERSION)" -lt "$(version_code $latest_release)" ]; then
		read -p "New version is found ($latest_release), update now? [Y/n] " confirm_update
		case $confirm_update in
		y | Y) ;;
		*) echo "Aborted." && exit 0 ;;
		esac
	else
		echo "error: Unexpected error on version_code()"
	fi

	if [ ! -z $install_deb ]; then
		start_throbber "Downloading update files..."
		rm -f $update_deb
		curl -o $update_deb -L https://github.com/Rem01Gaming/origami_kernel_manager/releases/download/$latest_release/origami-kernel.deb >/dev/null 2>&1
		stop_throbber
		[ ! -f $update_deb ] && echo "error: Can't download DEB package from GitHub release, check your Internet connection!" && exit 1
		start_throbber "Installing update..."
		apt remove origami-kernel -y >/dev/null 2>&1
		apt install $update_deb -y >/dev/null 2>&1
		rm -f $update_deb
		stop_throbber
		echo "Updated successfully to $latest_release :)"
	else
		if ! hash git; then
			echo "error: Environment has missing dependencies"
			exit 127
		fi
		whereami=$PWD
		start_throbber "Downloading update files..."
		git clone --depth 1 --branch $latest_release --single-branch https://github.com/Rem01Gaming/origami_kernel_manager.git $update_dir >/dev/null 2>&1
		stop_throbber
		[ ! -d $update_dir ] && echo "error: Can't git clone OKM repo, check your Internet connection!" && exit 1
		cd ~/.origami-kernel
		start_throbber "Installing update..."
		make uninstall >/dev/null 2>&1
		make install >/dev/null 2>&1
		cd $whereami
		rm -rf $update_dir
		stop_throbber
		echo "Updated successfully to $latest_release :)"
	fi
	exit 0
}

if [ -z $1 ]; then
	if [ -d /usr ]; then
		sudo okm-menu
	else
		okm-sudo okm-menu
	fi
	exit 0
fi

case $1 in
update) okm_update ;;
"help" | "--help") okm_show_usage ;;
*) echo -e "okm: Bad arguments\nTry 'okm help' for more information." ;;
esac
