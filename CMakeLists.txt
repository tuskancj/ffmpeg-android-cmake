# Sets the minimum version of CMake required to build your native library.
# This ensures that a certain set of CMake features is available to
# your build.

cmake_minimum_required(VERSION 3.4.1)

# Specifies a library name, specifies whether the library is STATIC or
# SHARED, and provides relative paths to the source code. You can
# define multiple libraries by adding multiple add_library() commands,
# and CMake builds them for you. When you build your app, Gradle
# automatically packages shared libraries with your APK.

#######################################
# directories
#######################################
 set(ffmpeg_DIR ${CMAKE_SOURCE_DIR}/src/main/cpp/ffmpeg)
 set(cpp_DIR ${CMAKE_SOURCE_DIR}/src/main/cpp)

#######################################
# add libraries
#######################################
 #av codec
 add_library(avcodec-57 SHARED IMPORTED)
 set_target_properties(avcodec-57
                        PROPERTIES
                        IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/libavcodec-57.so
                        INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/include)

 #av device
 add_library(avdevice-57 SHARED IMPORTED)
 set_target_properties(avdevice-57
                        PROPERTIES
                        IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/libavdevice-57.so
                        INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/include)

 #av filter
 add_library(avfilter-6 SHARED IMPORTED)
 set_target_properties(avfilter-6
                        PROPERTIES
                        IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/libavfilter-6.so
                        INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/include)

 #av format
 add_library(avformat-57 SHARED IMPORTED)
 set_target_properties(avformat-57
                        PROPERTIES
                        IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/libavformat-57.so
                        INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/include)

 #av util
 add_library(avutil-55 SHARED IMPORTED)
 set_target_properties(avutil-55
                        PROPERTIES
                        IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/libavutil-55.so
                        INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/include)

 #postproc
 add_library(postproc-54 SHARED IMPORTED)
 set_target_properties(postproc-54
                        PROPERTIES
                        IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/libpostproc-54.so
                        INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/include)

 #sw resample
 add_library(swresample-2 SHARED IMPORTED)
 set_target_properties(swresample-2
                        PROPERTIES
                        IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/libswresample-2.so
                        INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/include)

 #sw scale
 add_library(swscale-4 SHARED IMPORTED)
 set_target_properties(swscale-4
                        PROPERTIES
                        IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/libswscale-4.so
                        INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/include)

 #native library
 add_library(native-lib SHARED ${cpp_DIR}/native-lib.c)
 include_directories(${cpp_DIR}/native-lib.h)

 #log library
 find_library( # Defines the name of the path variable that stores the
              # location of the NDK library.
              log-lib

              # Specifies the name of the NDK library that
              # CMake needs to locate.
              log )

 #source files (ffmpeg and coffeecatch)
 add_library(ffmpeg STATIC ${cpp_DIR}/ffmpeg/build_noConfig/ffmpeg.c
                           ${cpp_DIR}/ffmpeg/build_noConfig/ffmpeg_filter.c
                           ${cpp_DIR}/ffmpeg/build_noConfig/ffmpeg_opt.c
                           ${cpp_DIR}/ffmpeg/build_noConfig/cmdutils.c
                           ${cpp_DIR}/ffmpeg/build_noConfig/libavutil/log.c)
 target_include_directories(ffmpeg PRIVATE ${ffmpeg_DIR}/${ANDROID_ABI}
                                           ${ffmpeg_DIR}/build_noConfig)

###################################
# link libraries
###################################
target_link_libraries( # Specifies the target libraries.
                       native-lib
                       ffmpeg
                       avutil-55
                       avformat-57
                       avcodec-57
                       avdevice-57
                       avfilter-6
                       postproc-54
                       swresample-2
                       swscale-4

                       # Links the target libraries to the log library
                       # included in the NDK.
                       ${log-lib})



