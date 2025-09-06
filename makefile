# ---- Configuration -----------------------------------------------------------
SCHEME            := HanyuPinyinIME
TEST_TARGET       := HanyuPinyinIMETests
CONFIG            := Debug
DEST              := platform=macOS,arch=arm64
DERIVED_DATA      := $(PWD)/build/DerivedData
RESULT_BUNDLE     := $(PWD)/build/TestResults.xcresult
PROJECT           := HanyuPinyinIME.xcodeproj

# App bundle and install path
APP_NAME          := Hanyu Pinyin.app
APP_PATH          := $(DERIVED_DATA)/Build/Products/$(CONFIG)/$(APP_NAME)
APP_BIN           := $(APP_PATH)/Contents/MacOS/Hanyu\ Pinyin
INSTALL_DIR       := $(HOME)/Library/Input Methods

# ---- Phony targets -----------------------------------------------------------
.PHONY: help build test test-clean open-results clean reset show kill run install

help:
	@echo "make build         # Build the app"
	@echo "make test          # Run unit tests (writes $(RESULT_BUNDLE))"
	@echo "make test-clean    # Clean result bundle then run tests"
	@echo "make install       # Copy built app into ~/Library/Input Methods"
	@echo "make run           # Launch the built app"
	@echo "make kill          # Kill any running 'Hanyu Pinyin' process"
	@echo "make open-results  # Open the latest xcresult in Xcode"
	@echo "make show          # Show TEST_HOST/BUNDLE_LOADER/etc"
	@echo "make clean         # Clean build artifacts only"
	@echo "make reset         # Remove repo-local DerivedData entirely"

# ---- Build & Test ------------------------------------------------------------
build:
	xcodebuild \
	  -project "$(PROJECT)" \
	  -scheme "$(SCHEME)" \
	  -configuration "$(CONFIG)" \
	  -destination '$(DEST)' \
	  -derivedDataPath "$(DERIVED_DATA)" \
	  build

test:
	xcodebuild \
	  -project "$(PROJECT)" \
	  -scheme "$(SCHEME)" \
	  -configuration "$(CONFIG)" \
	  -destination '$(DEST)' \
	  -derivedDataPath "$(DERIVED_DATA)" \
	  -resultBundlePath "$(RESULT_BUNDLE)" \
	  test

test-clean: kill
	rm -rf "$(RESULT_BUNDLE)"
	$(MAKE) test

# ---- Results & Debugging -----------------------------------------------------
open-results:
	open "$(RESULT_BUNDLE)"

show:
	@xcodebuild -showBuildSettings \
	  -project "$(PROJECT)" \
	  -configuration "$(CONFIG)" \
	  -target "$(TEST_TARGET)" \
	| grep -E 'TEST_HOST|BUNDLE_LOADER|EXECUTABLE_PATH|FULL_PRODUCT_NAME|PRODUCT_NAME' || true
	@echo
	@echo "App path: $(APP_PATH)"

# ---- Run / Kill --------------------------------------------------------------
kill:
	-@pkill -x "Hanyu Pinyin" || true

run: build
	open "$(APP_PATH)"

# ---- Install ----------------------------------------------------------------
install: build
	@echo "Installing $(APP_NAME) to $(INSTALL_DIR)"
	mkdir -p "$(INSTALL_DIR)"
	rm -rf "$(INSTALL_DIR)/$(APP_NAME)"
	cp -R "$(APP_PATH)" "$(INSTALL_DIR)/"
	xattr -dr com.apple.quarantine "$(INSTALL_DIR)/$(APP_NAME)" || true
	@echo "Installed. You may need to log out/in or toggle the input method in System Settings."

# ---- Cleaning ----------------------------------------------------------------
clean:
	xcodebuild \
	  -project "$(PROJECT)" \
	  -scheme "$(SCHEME)" \
	  -configuration "$(CONFIG)" \
	  -derivedDataPath "$(DERIVED_DATA)" \
	  clean

reset: kill
	rm -rf "$(DERIVED_DATA)"
	rm -rf "$(RESULT_BUNDLE)"
	@echo "Repo-local DerivedData removed."
