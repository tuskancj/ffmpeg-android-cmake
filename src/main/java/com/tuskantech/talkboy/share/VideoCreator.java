/*
 * Talkboy
 * Copyright (C) 2018 Charles Tuskan
 */

package com.tuskantech.talkboy.share;
public class VideoCreator {

    private static VideoCreator instance;
    public static VideoCreator getInstance(){
        if(instance == null){
            System.loadLibrary("native-lib");
            instance = new VideoCreator();
        }
        return instance;
    }

    private VideoCreator(){
    }

    public native int RunCommand(String[] argv) throws Exception;
    public native void StopProcess() throws Exception;
}
