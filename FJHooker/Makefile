GO_EASY_ON_ME = 1

ARCHS = arm64 arm64e
TARGET := iphone:clang:14.4:10.3

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = FJHooker

FJHooker_FILES = Tweak.xm
FJHooker_PUBLIC_HEADERS = FJHooker.h
FJHooker_INSTALL_PATH = /usr/lib
FJHooker_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/library.mk
