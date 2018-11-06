#!/bin/bash
#Change NDK to your Android NDK location
NDK=/home/tuskantech/Desktop/android-ndk-r14b
PLATFORM=$NDK/platforms/android-23/arch-x86/
PREBUILT=$NDK/toolchains/x86-4.9/prebuilt/linux-x86_64

GENERAL="\
--enable-small \
--enable-cross-compile \
--target-os=linux \
--enable-shared \
--disable-static \
--enable-pic \
--disable-asm \
--disable-doc "
#--disable-asm required on x86 otherwise you will get "text relocation" errors

MODULES="\
--enable-gpl \
--enable-version3 \
--enable-libx264 \
--enable-zlib "

ARCH="\
--arch=x86 \
--cpu=i686 \
--enable-runtime-cpudetect "

CFLAGS="-O2 -m32 -mfpmath=sse -fPIC -pipe -DANDROID -march=i686 -mtune=generic"
LDFLAGS="-lx264 -lz -Wl,-Bsymbolic,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib -lc -lm -ldl -llog"

X264_LIB="\
--extra-cflags="-I../x264_builds_ndk-r14b_api23/android/x86/include" \
--extra-ldflags="-L../x264_builds_ndk-r14b_api23/android/x86/lib" "

#this file can throw errors - apparently it's not important...
rm -f $(pwd)/compat/strtod.o

function build_x86
{
  ./configure \
  --logfile=conflog.txt \
  ${GENERAL} \
  ${ARCH} \
  --prefix=./android/x86 \
  --extra-libs="-lgcc" \
  --cc=$PREBUILT/bin/i686-linux-android-gcc \
  --cross-prefix=$PREBUILT/bin/i686-linux-android- \
  --nm=$PREBUILT/bin/i686-linux-android-nm \
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

build_x86


echo Android X86 builds finished
