GO_EASY_ON_ME = 1
FINALPACKAGE=1
DEBUG=0

THEOS_DEVICE_IP = 127.0.0.1 -p 2222

ARCHS := arm64 arm64e
TARGET := iphone:clang:13.1:7.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FlyJBX
$(TWEAK_NAME)_FILES = fishhook/fishhook.c Tweaks/FJPattern.xm Tweaks/Tweak.xm Tweaks/LibraryHooks.xm Tweaks/ObjCHooks.xm Tweaks/OptimizeDisableInjector.xm Tweaks/SysHooks.xm Tweaks/NoSafeMode.xm Tweaks/MemHooks.xm Tweaks/CheckHooks.xm Tweaks/PatchFinder.xm Tweaks/AeonLucid.xm ImportHooker/ImportHooker.c
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
before-package::
	mkdir -p $(THEOS_STAGING_DIR)/usr/lib/
	ldid -S -M -Ksigncert.p12 $(THEOS_STAGING_DIR)/usr/lib/FJHooker.dylib
	chmod 755 $(THEOS_STAGING_DIR)/Applications/FlyJB.app/FlyJB
	ldid -Sappent.xml $(THEOS_STAGING_DIR)/Applications/FlyJB.app/FlyJB

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += FJHooker
include $(THEOS_MAKE_PATH)/aggregate.mk
