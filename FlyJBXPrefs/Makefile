GO_EASY_ON_ME = 1

ARCHS := arm64 arm64e
TARGET := iphone:clang:13.1:7.1

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = FlyJBXPrefs
$(BUNDLE_NAME)_FILES = FJRootListController.m FJBypassListController.m FJOptimizeListController.m FJDisablerListController.m
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_FRAMEWORKS = UIKit
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_LIBRARIES = MobileGestalt applist

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/FlyJBXPrefs.plist$(ECHO_END)
