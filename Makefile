all: cloud-init-package

VERSION ?= $(shell git describe --tags)
WINE=/usr/bin/wine

cloud-init-package:
	$(WINE) "C:\Program Files (x86)\Inno Setup 5\iscc.exe" cloud-init.iss -DMyAppVersion=$(VERSION)
