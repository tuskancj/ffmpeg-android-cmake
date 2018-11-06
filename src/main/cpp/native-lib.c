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

#include <string.h>
#include <stdlib.h>
#include "native-lib.h"
#include <syslog.h>
#include "ffmpeg/build_noConfig/Logger.h"
#include <android/log.h>

int main_ffmpeg(int argc, char **argv);
int stop_process;

JNIEXPORT void JNICALL
Java_com_tuskantech_talkboy_share_VideoCreator_StopProcess(JNIEnv *env, jobject obj){
    stop_process = 1;
}

JNIEXPORT jint JNICALL
Java_com_tuskantech_talkboy_share_VideoCreator_RunCommand(JNIEnv *env,
                                                    jobject obj/* this */,
                                                    jobjectArray args) {
    int result = 1;
    //0 is no error

    int i = 0;
    int argc = 0;
    char **argv = NULL;
    jstring *strr = NULL;

    if (args != NULL) {
        argc = (*env)->GetArrayLength(env, args);
        argv = (char **) malloc(sizeof(char *) * argc);
        strr = (jstring *) malloc(sizeof(jstring) * argc);

        for(i=0;i<argc;i++)
        {
            strr[i] = (jstring)(*env)->GetObjectArrayElement(env, args, i);
            argv[i] = (char *)(*env)->GetStringUTFChars(env, strr[i], 0);
        }
    }

    result = main_ffmpeg(argc, argv);

    for(i=0;i<argc;i++)
    {
        (*env)->ReleaseStringUTFChars(env, strr[i], argv[i]);
    }
    free(argv);
    free(strr);

    //LOGI("MAIN_RETURN_RESULT AFTER SUCCESS:  %d", result);
    return result;
}