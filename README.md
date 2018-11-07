# ffmpeg-android-cmake
build ffmpeg with x264 for Android armeabi-v7a, arm64-v8a, x86, and x86_64 architectures utilizing CMake to compile into native libraries

## About
This project uses ffmpeg 3.2.12 and NDK r14b which are older versions, but they accomplish the simple task I needed done.
I'm mainly posting this to comply with the GNU General Public License v3.0 since this is the exact ffmpeg source code that the 'future app' uses to encode its videos.
But I also feel like my struggles need to be publicly documented so it may be easier for others to compile ffmpeg on Android via NDK.  

'future app' combines a single image with an audio clip that potentially has an odd sample rate (24320 Hz or 43200 Hz).  Due to the odd audio sampling rates which (as far as I understand) would need to be re-sampled to do any encoding via Android, it was decided to go with ffmpeg since it is a powerful platform and I could use it for other things down the road.  How hard could it be, right??
Turns out I spent way more time than I really wanted to, partially because a lot of the ffmpeg for Android tutorials are very outdated.  Lucky for you, people like [tanersener](https://github.com/tanersener/mobile-ffmpeg) have come along in the past few months and blown my project out of the water.  I have not tested his project but stumbled across it as I was putting this together and it looks like the real-deal. So for a complete turn-key solution check out his repository.

## Main steps
I'm going to assume you know how to run shell scripts using the Linux terminal.
1. PLEASE DO NOT USE WINDOWS TO COMPILE ANYTHING. I used Linux Ubuntu 18.04.1 LTS.  Mac can be used, but you'll have to reference other tutorials and change the necessary lines of code in the shell scripts.
2. Download the necessary platforms:
- [NDK r14b](https://developer.android.com/ndk/downloads/older_releases)
- [ffmpeg 3.2.12](https://www.ffmpeg.org/download.html)
- [x264](https://www.videolan.org/developers/x264.html)
3. Build the libraries:
  - external libraries first --> put the x264 .sh files (from the x264_shells folder in my repository) into the extracted x264 folder and run "./build_android_all.sh" from the terminal to build the x264 libraries for each architecture.
  - next edit the ffmpeg .sh files so that the correct path to your NDK file is specified and also the path to your x264 libraries for the compiler/linker flags.
4. Implement NDK into your android project
  - the CMakeLists.txt file is where the magic happens.  I'm by no means an expert with this, but figured out how to make CMake work by looking at numerous ndk-build files.  Android recommends using CMake now, so of course I was hell-bent on doing so...


.....more to come
