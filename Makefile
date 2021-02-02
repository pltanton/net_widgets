.POSIX:
PREFIX = ~/.local
.PHONY: install uninstall cronadd
install:
	@chmod 755 ntotal
	@mkdir -p ${DESTDIR}${PREFIX}/bin
	@cp -vf ntotal ${DESTDIR}${PREFIX}/bin
	@echo Done installing
uninstall:
	@rm -vf ${DESTDIR}${PREFIX}/bin/ntotal
	@echo Done uninstalling
