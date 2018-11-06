#!/bin/bash
#Change NDK to your Android NDK location
NDK=/home/tuskantech/Desktop/android-ndk-r14b
PLATFORM=$NDK/platforms/android-23/arch-x86_64/
PREBUILT=$NDK/toolchains/x86_64-4.9/prebuilt/linux-x86_64

GENERAL="\
--enable-small \
--enable-cross-compile \
--target-os=linux \
--enable-shared \
--disable-static \
--enable-pic \
--disable-doc "

MODULES="\
--enable-gpl \
--enable-version3 \
--enable-libx264 \
--enable-zlib "

ARCH="\
--arch=x86_64 \
--cpu=x86_64 \
--enable-runtime-cpudetect "

CFLAGS="-O2 -pipe -march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=generic -DANDROID"
LDFLAGS="-lx264 -lz -Wl,-rpath-link=$PLATFORM/usr/lib64 -L$PLATFORM/usr/lib64 -nostdlib -lc -lm -ldl -llog"

X264_LIB="\
--extra-cflags="-I../x264_builds_ndk-r14b_api23/android/x86_64/include" \
--extra-ldflags="-L../x264_builds_ndk-r14b_api23/android/x86_64/lib" "

#this file can throw errors - apparently it's not important...
rm -f $(pwd)/compat/strtod.o

function build_x86_64
{
  ./configure \
  --logfile=conflog.txt \
  ${GENERAL} \
  ${ARCH} \
  --prefix=./android/x86_64 \
  --extra-libs="-lgcc" \
  --cc=$PREBUILT/bin/x86_64-linux-android-gcc \
  --cross-prefix=$PREBUILT/bin/x86_64-linux-android- \
  --nm=$PREBUILT/bin/x86_64-linux-android-nm \
  --sysroot=${PLATFORM} \
  ${MODULES} \
  --extra-cflags="$CFLAGS" \
  --extra-cxxflags="$CFLAGS" \
  --extra-ldflags="$LDFLAGS" \
  ${X264_LIB} \
  $ADDITIONAL_CONFIGURE_FLAG

  make clean
  make -j4
  make install
}

build_x86_64


echo Android X86_64 builds finished
