/*
 * Copyright (C) 2018 Charles Tuskan

 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include <jni.h>

#ifndef TALKBOY_NATIVE_LIB_H
#define TALKBOY_NATIVE_LIB_H

#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     com_madhavanmalolan_ffmpegandroidlibrary_Controller
 * Method:    run
 * Signature: ([Ljava/lang/String;)V
 */
JNIEXPORT jint JNICALL Java_com_tuskantech_talkboy_share_VideoCreator_RunCommand
(JNIEnv *, jobject, jobjectArray);

JNIEXPORT void JNICALL Java_com_tuskantech_talkboy_share_VideoCreator_StopProcess
        (JNIEnv *, jobject);

#ifdef __cplusplus
}
#endif

#endif //TALKBOY_NATIVE_LIB_H

