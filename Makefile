export ARCHS = armv7 armv7s arm64
export SDKVERSION = 7.1
export THEOS_BUILD_DIR = build_dir

include theos/makefiles/common.mk

BUNDLE_NAME = NCIP
NCIP_FILES = NCIPViewController.m
NCIP_INSTALL_PATH = /System/Library/WeeAppPlugins/
NCIP_FRAMEWORKS = UIKit CoreGraphics SystemConfiguration
NCIP_PRIVATE_FRAMEWORKS = SpringBoardUIServices

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
