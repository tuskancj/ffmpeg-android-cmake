#!/bin/bash
NDK=/home/tuskantech/Desktop/android-ndk-r14b
PLATFORM=$NDK/platforms/android-23/arch-mips64/
TOOLCHAIN=$NDK/toolchains/mips64el-linux-android-4.9/prebuilt/linux-x86_64
PREFIX=./android/mips64

function build_one
{
  ./configure \
  --prefix=$PREFIX \
  --enable-static \
  --enable-pic \
  --host=mips64el-linux \
  --cross-prefix=$TOOLCHAIN/bin/mips64el-linux-android- \
  --sysroot=$PLATFORM \
  --disable-asm

  make clean
  make -j4
  make install
}

build_one

echo Android MIPS_64 builds finished
