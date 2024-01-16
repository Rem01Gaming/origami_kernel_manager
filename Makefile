SCRIPT_NAME = origami-kernel
PREFIX = $(shell echo $$PREFIX)

all:
	@ echo "Use: make install, make uninstall"

install:
	cp origami-kernel $(PREFIX)/bin/$(SCRIPT_NAME)
	cp -r ./init $(PREFIX)/bin
	cp -r ./utils $(PREFIX)/bin
	chmod +x $(PREFIX)/bin/$(SCRIPT_NAME)
	@echo "$(SCRIPT_NAME) installed to $(PREFIX)/bin"

uninstall:
	rm -f $(PREFIX)/bin/$(SCRIPT_NAME)
	rm -rf $(PREFIX)/bin/init
	rm -rf $(PREFIX)/bin/utils
	@echo "$(SCRIPT_NAME) uninstalled from $(PREFIX)/bin"
