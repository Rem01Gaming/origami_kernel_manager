SCRIPT_NAME = origami-kernel
PREFIX = $(shell echo $$PREFIX)

all:
	@ echo "Use: make install, make uninstall"

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
