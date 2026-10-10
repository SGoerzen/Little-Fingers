PROJECT       := Little Fingers.xcodeproj
SCHEME        := Little Fingers
APP_NAME      := Little Fingers.app
CONFIGURATION ?= Release
BUILD_DIR     := build
DERIVED_DATA  := $(BUILD_DIR)/DerivedData
PRODUCT       := $(DERIVED_DATA)/Build/Products/$(CONFIGURATION)/$(APP_NAME)
INSTALL_DIR   ?= /Applications

XCODEBUILD := xcodebuild \
	-project "$(PROJECT)" \
	-scheme "$(SCHEME)" \
	-configuration $(CONFIGURATION) \
	-derivedDataPath "$(DERIVED_DATA)" \
	-destination 'platform=macOS'

.PHONY: all build debug release run install uninstall zip clean help

all: build

help:
	@echo "Targets:"
	@echo "  build      Build the app ($(CONFIGURATION) by default; override with CONFIGURATION=Debug)"
	@echo "  debug      Build the Debug configuration"
	@echo "  release    Build the Release configuration"
	@echo "  run        Build and launch the app"
	@echo "  install    Build and copy the app to $(INSTALL_DIR)"
	@echo "  uninstall  Remove the app from $(INSTALL_DIR)"
	@echo "  zip        Build and package the app as build/Little-Fingers.zip"
	@echo "  clean      Remove build artifacts"

build:
	$(XCODEBUILD) build
	@echo "Built: $(PRODUCT)"

debug:
	@$(MAKE) build CONFIGURATION=Debug

release:
	@$(MAKE) build CONFIGURATION=Release

run: build
	open "$(PRODUCT)"

install: build
	rm -rf "$(INSTALL_DIR)/$(APP_NAME)"
	cp -R "$(PRODUCT)" "$(INSTALL_DIR)/"
	@echo "Installed to $(INSTALL_DIR)/$(APP_NAME)"

uninstall:
	rm -rf "$(INSTALL_DIR)/$(APP_NAME)"

zip: build
	ditto -c -k --keepParent "$(PRODUCT)" "$(BUILD_DIR)/Little-Fingers.zip"
	@echo "Packaged: $(BUILD_DIR)/Little-Fingers.zip"

clean:
	rm -rf "$(BUILD_DIR)"
