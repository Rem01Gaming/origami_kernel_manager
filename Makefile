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

SCRIPT_NAME = origami-kernel
PREFIX = $(shell echo $$PREFIX)

all:
	@echo "Available commands:"
	@echo "make install : Install directly to your termux"
	@echo "make uninstall : Uninstall from your termux"
	@echo "make install-dependence : Install needed dependencines"

install:
	cp origami-kernel $(PREFIX)/bin/$(SCRIPT_NAME)
	mkdir $(PREFIX)/share/origami-kernel
	cp -r ./init $(PREFIX)/share/origami-kernel
	cp -r ./utils $(PREFIX)/share/origami-kernel
	chmod +x $(PREFIX)/bin/$(SCRIPT_NAME)
	@echo "$(SCRIPT_NAME) installed to $(PREFIX)/bin"

uninstall:
	rm -f $(PREFIX)/bin/$(SCRIPT_NAME)
	rm -rf $(PREFIX)/share/origami-kernel
	@echo "$(SCRIPT_NAME) uninstalled from $(PREFIX)/bin"

install-dependence:
	@echo "[+] Installing dependencines..."
	@pkg install make fzf fzy git tsu jq
