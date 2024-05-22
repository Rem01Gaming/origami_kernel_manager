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

O = out
.PHONY: all
PREFIX = $(shell echo $$PREFIX)

all:
	@echo "Available commands:"
	@echo "make install : Install directly to your termux"
	@echo "make uninstall : Uninstall from your termux"
	@echo "make install-dependence : Install needed dependencines"
	@echo "make pack-deb : Build deb package"

install:
	cp ./src/origami-kernel $(PREFIX)/bin
	cp ./src/origami-sudo $(PREFIX)/bin
	mkdir $(PREFIX)/share/origami-kernel
	cp -r ./share/* $(PREFIX)/share/origami-kernel
	chmod +x $(PREFIX)/bin/origami-kernel
	chmod +x $(PREFIX)/bin/origami-sudo
	@printf "\033[1;38;2;254;228;208m    .^.   .^.\n"
	@printf "    /⋀\\_ﾉ_/⋀\\ \n"
	@printf "   /ﾉｿﾉ\\ﾉｿ丶)|\n"
	@printf "  |ﾙﾘﾘ >   )ﾘ\n"
	@printf "  ﾉノ㇏ Ｖ ﾉ|ﾉ\n"
	@printf "        ⠁⠁\n"
	@printf "\033[1;38;2;254;228;208m[+] origami-kernel installed, run with origami-kernel\033[0m\n"

uninstall:
	rm -f $(PREFIX)/bin/origami-kernel $(PREFIX)/bin/origami-sudo
	rm -rf $(PREFIX)/share/origami-kernel
	@printf "\033[1;38;2;254;228;208m[+] origami-kernel uninstalled\033[0m\n"

install-dependence:
	@echo "\033[1;38;2;254;228;208m[+] Installing dependencines...\033[0m"
	@apt install root-repo -y
	@apt install fzf fzy git jq  -y

pack-deb:
	@mkdir -v $(O)
	@mkdir -v $(O)/deb
	@mkdir -pv $(O)/deb/data/data/com.termux/files/usr
	@mkdir -pv $(O)/deb/data/data/com.termux/files/usr/bin/
	@mkdir -pv $(O)/deb/data/data/com.termux/files/usr/share/origami-kernel/
	@mkdir -pv $(O)/deb/data/data/com.termux/files/usr/share/origami-kernel/doc
	@cp -rv share/* $(O)/deb/data/data/com.termux/files/usr/share/origami-kernel/
	@cp -rv src/* $(O)/deb/data/data/com.termux/files/usr/bin/
	@cp -rv doc/* $(O)/deb/data/data/com.termux/files/usr/share/origami-kernel/doc
	@cp -rv dpkg-conf $(O)/deb/DEBIAN
	@printf "\033[1;38;2;254;228;208m[+] Build packages.\033[0m\n"&&sleep 1s
	@chmod -Rv 755 $(O)/deb/DEBIAN
	@chmod -Rv 755 $(O)/deb/data/data/com.termux/files/usr/bin
	@chmod -Rv 777 $(O)/deb/data/data/com.termux/files/usr/bin/origami-kernel
	@chmod -Rv 777 $(O)/deb/data/data/com.termux/files/usr/bin/origami-sudo
	@cd $(O)/deb&&dpkg -b . ../../origami-kernel.deb
	@printf "\033[1;38;2;254;228;208m    .^.   .^.\n"
	@printf "    /⋀\\_ﾉ_/⋀\\ \n"
	@printf "   /ﾉｿﾉ\\ﾉｿ丶)|\n"
	@printf "  |ﾙﾘﾘ >   )ﾘ\n"
	@printf "  ﾉノ㇏ Ｖ ﾉ|ﾉ\n"
	@printf "        ⠁⠁\n"
	@printf "\033[1;38;2;254;228;208m[*] Build done,package: origami-kernel.deb\033[0m\n"
	@rm -rf ./out
