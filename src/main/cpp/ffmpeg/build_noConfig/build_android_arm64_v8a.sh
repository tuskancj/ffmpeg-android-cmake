#!/bin/bash
#Change NDK to your Android NDK location
NDK=/home/tuskantech/Desktop/android-ndk-r14b
PLATFORM=$NDK/platforms/android-23/arch-arm64/
PREBUILT=$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64

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
--arch=aarch64 \
--cpu=armv8-a \
--enable-runtime-cpudetect "

CFLAGS="-pipe -DANDROID -fasm -O2 -march=armv8-a -mtune=generic"
LDFLAGS="-lx264 -lz -Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib -lc -lm -ldl -llog"

X264_LIB="\
--extra-cflags="-I../x264_builds_ndk-r14b_api23/android/arm64/include" \
--extra-ldflags="-L../x264_builds_ndk-r14b_api23/android/arm64/lib" "

#this file can throw errors - apparently it's not important...
rm -f $(pwd)/compat/strtod.o

function build_arm64
{
  ./configure \
  --logfile=conflog.txt \
  ${GENERAL} \
  ${ARCH} \
  --prefix=./android/arm64-v8a \
  --extra-libs="-lgcc" \
  --cc=${PREBUILT}/bin/aarch64-linux-android-gcc \
  --cross-prefix=${PREBUILT}/bin/aarch64-linux-android- \
  --nm=${PREBUILT}/bin/aarch64-linux-android-nm \
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

build_arm64

echo Android ARM64 builds finished

MODULES3="\
--enable-gpl \
--enable-version3 \
--enable-sdl2 \
--enable-bzlib \
--enable-fontconfig \
--enable-gnutls \
--enable-iconv \
--enable-libass \
--enable-libfreetype \
--enable-libmp3lame \
--enable-libopencore-amrnb \
--enable-libopencore-amrwb \
--enable-libopenjpeg \
--enable-libopus \
--enable-libshine \
--enable-libsnappy \
--enable-libsoxr \
--enable-libtheora \
--enable-libtwolame \
--enable-libvpx \
--enable-libwavpack \
--enable-libwebp \
--enable-libx264 \
--enable-libx265 \
--enable-libxml2
--enable-libzimg \
--enable-lzma \
--enable-zlib \
--enable-gmp \
--enable-libvidstab \
--enable-libvorbis \
--enable-libvo-amrwbenc \
--enable-libmysofa \
--enable-libspeex \
--enable-libxvid \
--enable-libaom "

COMPONENTS="\
--enable-muxer=avi \
--enable-demuxer=avi \
--enable-encoder=mpeg4 \
--enable-decoder=mpeg4 \
--enable-encoder=mp2 \
--enable-decoder=mp2 "
