SCRIPT_NAME = origami-kernel
PREFIX = $(shell echo $$PREFIX)

all:
	@ echo "Use: make install, make uninstall"

install:
	shc -r -v -f $(SCRIPT_NAME)
	cp $(SCRIPT_NAME).x $(PREFIX)/bin/$(SCRIPT_NAME)
	chmod +x $(PREFIX)/bin/$(SCRIPT_NAME)
	@echo "$(SCRIPT_NAME) installed to $(PREFIX)/bin"

uninstall:
	rm -f $(PREFIX)/bin/$(SCRIPT_NAME)
	@echo "$(SCRIPT_NAME) uninstalled from $(PREFIX)/bin"
