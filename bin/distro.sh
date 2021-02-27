#!/bin/bash
# author: William Vabrinskas
# Builds tweak with a legacy arm64e slice and the most recent arm64e slice

# README:
# Xcode 11.7 is required!
# Make sure your Makefile is building for arm64 and arm64e 

# Requirements: 
# a patched version of lipo, available here: https://github.com/Matchstic/iOSOpenDev/blob/master/bin/lipo

# Usage: 
# 1. Create a folder named bin, and place this script in it. 
# 2. Download the modified lipo linked above and name it lipo_patched
# 3. Place lipo_patched in the newly create bin directory. 

rm -rf ./bin/tmp
mkdir ./bin/tmp

#Version, only used to name the package
VERSION="1.0"

#Name for tweak
NAME="FlyJBX"
NAME2="FJHooker"

# Pref name for tweak
PREF_NAME="FlyJBXPrefs"

# Archs for logging print. 
ARCHS="arm64 arm64e"

#Xcode 11 dir
XCODE11=/Applications/Xcode_11.7.app/Contents/Developer

#Xcode 12+ dir
XCODE=/Applications/Xcode.app/Contents/Developer

bold=$(tput bold)
normal=$(tput sgr0)

BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

sudo xcode-select -s ${XCODE}

echo -e "Making ${BGreen}${ARCHS}${normal} for ${BGreen}$(sudo xcode-select -p)${normal}"

make clean
make package

cp .theos/_/Library/MobileSubstrate/DynamicLibraries/${NAME}.dylib ./bin/tmp/arm64e.dylib
cp .theos/_/usr/lib/${NAME2}.dylib ./bin/tmp/arm64e
#cp .theos/_/Library/PreferenceBundles/${PREF_NAME}.bundle/${PREF_NAME} ./bin/tmp/arm64e

#swap xcodes to use xcode11
sudo xcode-select -s ${XCODE11}

echo -e "Making ${BGreen}${ARCHS}${normal} for ${BGreen}$(sudo xcode-select -p)${normal}"

make clean
make package

cp .theos/_/Library/MobileSubstrate/DynamicLibraries/${NAME}.dylib ./bin/tmp/arm64e_legacy.dylib
cp .theos/_/usr/lib/${NAME2}.dylib ./bin/tmp/arm64e_legacy
#cp .theos/_/Library/PreferenceBundles/${PREF_NAME}.bundle/${PREF_NAME} ./bin/tmp/arm64e_legacy

echo -e "${BGreen} Stripping extra arm64 architecture from legacy build ${normal}"
./bin/lipo_patched -remove arm64 ./bin/tmp/arm64e_legacy.dylib -o ./bin/tmp/arm64e_legacy_stripped.dylib  
./bin/lipo_patched -remove arm64 ./bin/tmp/arm64e_legacy -o ./bin/tmp/arm64e_legacy_stripped  

rm -rf ./bin/tmp/arm64e_legacy.dylib
rm -rf ./bin/tmp/arm64e_legacy

mv ./bin/tmp/arm64e_legacy_stripped.dylib ./bin/tmp/arm64e_legacy.dylib
mv ./bin/tmp/arm64e_legacy_stripped ./bin/tmp/arm64e_legacy

echo -e "${BGreen} Combining both arm64e architectures ${normal}"
#presign -- don't know if this is needed but why not
ldid2 -S ./bin/tmp/arm64e.dylib
ldid2 -S ./bin/tmp/arm64e_legacy.dylib

ldid2 -S ./bin/tmp/arm64e
ldid2 -S ./bin/tmp/arm64e_legacy

./bin/lipo_patched -create ./bin/tmp/arm64e_legacy.dylib ./bin/tmp/arm64e.dylib -output ./bin/tmp/${NAME}.dylib
./bin/lipo_patched -create ./bin/tmp/arm64e_legacy ./bin/tmp/arm64e -output ./bin/tmp/${NAME2}.dylib

echo -e "${BGreen} Done! ${normal}"
file ./bin/tmp/${NAME}.dylib
file ./bin/tmp/${NAME2}.dylib

echo -e "${BYellow} Signing binary... ${normal}"
ldid2 -S ./bin/tmp/${NAME}.dylib
ldid2 -S ./bin/tmp/${NAME2}.dylib

echo -e "${BYellow} Resetting xcode back to latest version ${normal}"

#swap Xcodes back
sudo xcode-select -s ${XCODE}

echo -e "${BGreen} Done! Xcode: $(sudo xcode-select -p)${normal}"

echo -e "${BYellow} Building package... ${normal}"

rm -rf ./bin/tmp/deb
mkdir ./bin/tmp/deb

cp -r .theos/_ ./bin/tmp/deb/_

DEB_DIR=./bin/tmp/deb/${NAME}_${VERSION}

mv ./bin/tmp/deb/_ ${DEB_DIR}

echo -e "${BYellow} Moving binary... ${normal}"
rm -rf ${DEB_DIR}/Library/MobileSubstrate/DynamicLibraries/${NAME}.dylib
rm -rf ${DEB_DIR}/usr/lib/${NAME2}.dylib

mv ./bin/tmp/${NAME}.dylib ${DEB_DIR}/Library/MobileSubstrate/DynamicLibraries/
mv ./bin/tmp/${NAME2}.dylib ${DEB_DIR}/usr/lib/

echo -e "${BYellow} Verifying binary move... ${normal}"
file ${DEB_DIR}/Library/MobileSubstrate/DynamicLibraries/${NAME}.dylib
file ${DEB_DIR}/usr/lib/${NAME2}.dylib

echo -e "${BYellow} Make load binary first... ${normal}"
mv "${DEB_DIR}/Library/MobileSubstrate/DynamicLibraries/FlyJBX.dylib" "${DEB_DIR}/Library/MobileSubstrate/DynamicLibraries/ FlyJBX.dylib"
mv "${DEB_DIR}/Library/MobileSubstrate/DynamicLibraries/FlyJBX.plist" "${DEB_DIR}/Library/MobileSubstrate/DynamicLibraries/ FlyJBX.plist"

dpkg-deb -b ${DEB_DIR}

open ./bin/tmp/deb/

echo -e "${BGreen} Done! ${normal}"
