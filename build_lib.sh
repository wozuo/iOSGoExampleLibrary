#!/bin/bash

# Build the library

DEVELOPER_DIR=`xcode-select --print-path`
IOS_MIN_VERSION="11.0" #iOS 11 gets rid of 32 bit support
OSX_MIN_VERSION="10.8"

IPHONEOS_SDK_VERSION=`xcodebuild -version -sdk | grep -A 1 '^iPhoneOS' | tail -n 1 |  awk '{ print $2 }'`
IPHONEOS_SDK_PATH="$DEVELOPER_DIR/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS$IPHONEOS_SDK_VERSION.sdk"

IPHONESIMULATOR_SDK_VERSION=`xcodebuild -version -sdk | grep -A 1 '^iPhoneSimulator' | tail -n 1 |  awk '{ print $2 }'`
IPHONESIMULATOR_SDK_PATH="$DEVELOPER_DIR/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator$IPHONESIMULATOR_SDK_VERSION.sdk"

MACOSX_SDK_VERSION=`xcodebuild -version -sdk | grep -A 1 '^MacOSX' | tail -n 1 |  awk '{ print $2 }'`
MACOSX_SDK_PATH="$DEVELOPER_DIR/Platforms/MacOSX.platform/Developer/SDKs/MacOSX$MACOSX_SDK_VERSION.sdk"

build_ios_arm64() {
    export CC=`xcrun -find clang`
    export CXX=`xcrun -find clang++`

    export CGO_ENABLED=1
    export GOOS=darwin
    export GOARCH=arm64
    export CGO_CFLAGS="-isysroot $IPHONEOS_SDK_PATH -arch arm64 -miphoneos-version-min=$IOS_MIN_VERSION"
    export CGO_LDFLAGS="-isysroot $IPHONEOS_SDK_PATH -arch arm64 -miphoneos-version-min=$IOS_MIN_VERSION"

    go build -tags="ios" --buildmode=c-archive -o build/libhtmlescaper_ios_arm64.a
}

build_ios_simulator() {
    export CC=`xcrun -find clang`
    export CXX=`xcrun -find clang++`
    
    export CGO_ENABLED=1
    export GOOS=darwin
    export GOARCH=amd64
    export CGO_CFLAGS="-isysroot $IPHONESIMULATOR_SDK_PATH -arch x86_64 -mios-simulator-version-min=$IOS_MIN_VERSION"
    export CGO_LDFLAGS="-isysroot $IPHONESIMULATOR_SDK_PATH -arch x86_64 -mios-simulator-version-min=$IOS_MIN_VERSION"

    go build -tags="ios" --buildmode=c-archive -o build/libhtmlescaper_iossim_arm64.a
}

build_macos() {
    export CC=`xcrun -find clang`
    export CXX=`xcrun -find clang++`
    
    export CGO_ENABLED=1
    export GOOS=darwin
    export GOARCH=amd64
    export CGO_CFLAGS="-isysroot $MACOSX_SDK_PATH -arch x86_64 -mmacosx-version-min=$OSX_MIN_VERSION"
    export CGO_LDFLAGS="-isysroot $MACOSX_SDK_PATH -arch x86_64 -mmacosx-version-min=$OSX_MIN_VERSION"

    go build -tags="" --buildmode=c-archive -o build/libhtmlescaper_macos_amd64.a
}

echo "Building ios arm64..."
build_ios_arm64
echo "Building ios simulator..."
build_ios_simulator
echo "Building macOS..."
build_macos
echo "Done!"