#!/bin/bash
#Change NDK to your Android NDK location
NDK=/home/tuskantech/Desktop/android-ndk-r14b
PLATFORM=$NDK/platforms/android-23/arch-arm/
PREBUILT=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64

GENERAL="\
--enable-small \
--enable-cross-compile \
--target-os=linux \
--enable-shared \
--disable-static \
--enable-neon \
--enable-pic \
--disable-doc "

MODULES="\
--enable-gpl \
--enable-version3 \
--enable-libx264 \
--enable-zlib "

ARCH="\
--arch=arm \
--cpu=armv7-a \
--enable-runtime-cpudetect "

CFLAGS="-DANDROID -O2 -pipe -fPIC -ffunction-sections -funwind-tables -fstack-protector -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300"
LDFLAGS="-lx264 -lz -Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib -lc -lm -ldl -llog"

X264_LIB="\
--extra-cflags="-I../x264_builds_ndk-r14b_api23/android/arm/include" \
--extra-ldflags="-L../x264_builds_ndk-r14b_api23/android/arm/lib" "

#this file can throw errors - apparently it's not important...
rm -f $(pwd)/compat/strtod.o

function build_ARMv7
{
  ./configure \
  --logfile=conflog.txt \
  ${GENERAL} \
  ${ARCH} \
  --prefix=./android/armeabi-v7a \
  --extra-libs="-lgcc" \
  --cc=$PREBUILT/bin/arm-linux-androideabi-gcc \
  --cross-prefix=$PREBUILT/bin/arm-linux-androideabi- \
  --nm=$PREBUILT/bin/arm-linux-androideabi-nm \
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

build_ARMv7
echo Android ARMv7-a builds finished
