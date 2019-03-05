# ffmpeg-android-cmake
Build ffmpeg with x264 for Android armeabi-v7a, arm64-v8a, x86, and x86_64 architectures utilizing CMake to compile into native libraries.  This code is used by the [Talkboy](https://play.google.com/store/apps/details?id=com.tuskantech.talkboy) app available in the Google Play Store.  It strictly creates mp4 videos by looping a single image with a clip of audio using a single ffmpeg command.

## About
This project uses ffmpeg 3.2.12 and NDK r14b which are older versions, but they accomplish the simple task I needed done.
I'm mainly posting this to comply with the GNU General Public License v3.0 since this is the exact ffmpeg source code that the Talkboy app uses to encode its videos.  But I also feel like my struggles need to be publicly documented so it may be easier for others to compile ffmpeg on Android via NDK.  

Talkboy combines a single image with an audio clip that potentially has an odd sample rate (24320 Hz or 43200 Hz).  Due to the odd audio sampling rates which (as far as I understand) would need to be re-sampled to do any encoding via Android, it was decided to go with ffmpeg since it is a powerful platform and I could use it for other things down the road.  How hard could it be, right??
Turns out I spent way more time than I really wanted to, partially because a lot of the ffmpeg for Android tutorials are very outdated.  Lucky for you, people like [tanersener](https://github.com/tanersener/mobile-ffmpeg) have come along in the past few months and blown my project out of the water.  I have not tested his project but stumbled across it as I was putting this together and it looks like the real-deal. So for a complete turn-key solution check out his repository.

## Main steps
I'm going to assume you know how to run shell scripts using the Linux terminal.
1. DO NOT USE WINDOWS TO COMPILE ANYTHING. I used Linux Ubuntu 18.04.1 LTS.  Mac can be used, but you'll have to reference other tutorials and change the necessary lines of code in the shell scripts.
2. Download the necessary platforms:
- [NDK r14b](https://developer.android.com/ndk/downloads/older_releases)
- [ffmpeg 3.2.12](https://www.ffmpeg.org/download.html)
- [x264](https://www.videolan.org/developers/x264.html)
3. Build the libraries:
  - external libraries first --> put the x264 .sh files (from the x264_shells folder in my repository) into the extracted x264 folder and run "./build_android_all.sh" from the terminal to build the x264 libraries for each architecture.
  - next edit the ffmpeg .sh files so that the correct path to your NDK file is specified and also the path to your x264 libraries for the compiler/linker flags.
4. Implement NDK into your project
  - I pretty much followed this [Official Tutorial](https://developer.android.com/ndk/guides)
  - the CMakeLists.txt file is where the magic happens.  I'm by no means an expert with this, but figured out how to make CMake work by looking at numerous ndk-build files.  Android recommends using CMake now, so this is the route I chose.

## Implementation
You can see that the ffmpeg source file is called from my native-lib.c which is accessed via the JNI.  I have a VideoCreator.java class within Talkboy that accesses native-lib.c and you'll also notice two of the JNI methods that I use.  RunCommand() will run the ffmpeg command and StopProcess() will tell ffmpeg to stop doing whatever it's doing without crashing.  This is in case the user goes back or wants to cancel:

```java
public class VideoCreator {
    private Context currentContext;
    private static VideoCreator instance;
    public static VideoCreator getInstance(Context c){
        if(instance == null){
            System.loadLibrary("native-lib");
            instance = new VideoCreator(c);
        }
        return instance;
    }
    private VideoCreator(Context c){
        currentContext = c;
    }
    
    //ffmpeg jni
    public native int RunCommand(String[] argv) throws Exception;
    public native void StopProcess() throws Exception;
}
```

In the MainActivity of Talkboy, I initialize the VideoCreator class in a background thread.  I made it static since it takes a few seconds to initialize and I didn't want this to hinder the user experience.  I do this once when the app is opened:

```java
Thread t = new Thread(new Runnable() {
        @Override
        public void run() {
            android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_BACKGROUND);

            //null the current instance (might be unneccessary...)
            VideoCreator vc = VideoCreator.getInstance(c);
            vc = null;

            //create new instance
            VideoCreator.getInstance(c);
        }
    });
   t.start();
```

Once the VideoCreator class is initialized, I can call the RunCommand(String[] argv) with the ffmpeg command.  Obviously, this app only takes audio and an image and creates a video, so it is hard-coded, but this is where you can implement an input box, etc.  Keep in mind, the command has to be in this form, otherwise it will throw an exception.  Talkboy images are always a square with max 1080 pixels per side.  This is a lengthy command, but there was a lot of experimentation due to the desire to upload videos to social media sites with decent quality.  Sites like Instagram and Twitter are known to highly compress videos which degrade the quality.  The below seems to work well enough for max 1080p and 10 fps is the minimum I would go.

```java
VideoCreator.getInstance(c).RunCommand(new String[]{
        "ffmpeg", //program start command
        "-y", //overwrite output files without asking
        "-r", //input framerate of 1 fps
        "1",
        "-loop", //loop the same frame
        "1",
        "-i", //input to imagePath file location
        imagePath,
        "-i", //input to audio wav file
        FileManager.getTrimmedWAVAudioFilepath(c),
        "-r", //output framerate of 10 fps
        "10",
        "-c:v", //lib x264 encoder
        "libx264",
        "-x264-params", //set for constant bit rate (needs to be high for decent instagram quality)
        "nal-hrd=cbr",
        "-b:v", //bitrate of output file to 2Mbit/s
        "2M",
        "-minrate", //min bit rate of 2Mbit/s
        "2M",
        "-maxrate",  //max bit rate of 2Mbit/s
        "2M",
        "-bufsize",  //buffer size of 2Mbit/s
        "2M",
        "-tune", //tuning for slideshow like movie since one image
        "stillimage",
        "-pix_fmt", //frame picture format yuv420p
        "yuv420p",
        "-c:a", //aac encoder
        "aac",
        "-b:a", //audio bit rate
        "256k",
        "-ar", //audio sample rate
        "44100",
        "-ac", //stereo output (mono doesn't work on instagram...)
        "2",
        "-t", //time length equal to audio
        mp4_length, //(float to string with single dec place) found in separate method
        FileManager.getFinalOutputMovieFilepath(c) //output file
});
```

I also implemented a broadcast so a status bar could be applied to the ffmpeg process.  Basically, the way this works is by parsing the ffmpeg output dialog for the total duration and subsequent frame updates.  The notes below should help describe what's going on via the java side of things and you can search through the ffmpeg source code for my additions.  This method was placed in the VideoCreator.java Class:

```java
private double duration = 60.0;
private int percentage = 30;
public void broadcastEncodingStatus(String s){
    /*first string is the total duration, the following strings are status updates while encoding
    * 1. break up the total duration string to get only seconds, then convert to a percentage and broadcast
    *       it will be a string like the following:
    *       00:00:02.73
    * 2. break up the following strings by grabbing the time
    *       they will be strings like the following:
    *       frame=    0 fps=0.0 q=0.0 size=       0kB time=00:00:00.00 bitrate=N/A dup=108 drop=0 speed=   0x
    *       frame=   27 fps=0.0 q=0.0 size=       0kB time=00:00:00.00 bitrate=N/A dup=135 drop=0 speed=   0x
    *       frame=   27 fps= 23 q=0.0 size=       0kB time=00:00:01.02 bitrate=   0.0kbits/s dup=135 drop=0 speed=0.857x
    *       frame=   27 fps= 11 q=-1.0 Lsize=     689kB time=00:00:02.71 bitrate=2077.5kbits/s dup=135 drop=0 speed=1.14x
    *
    * The initial Talkboy video creation consists of
    * 1. saving the image to file
    * 2. creating the wav file from pcm
    * 3. getting the length of audio
    * 4. lastly encoding via ffmpeg
    *
    * so we will say the last 70% of time involves ffmpeg
    * therefore broadcasts will already include 30% assuming everything prior completed correctly*/
    if (!s.contains("time=")){ //this is the duration
        String seconds = s.split(":")[2];
        String minutes = s.split(":")[1];
        double mD = Double.parseDouble(minutes);
        duration = Double.parseDouble(seconds);
        if (mD>0){
            duration+=60;
        }
        percentage = 30;
    }
    else{ //these are the time updates
        String fullTime = s.split("time=")[1].substring(0, 10);
        String seconds = fullTime.split(":")[2];
        String minutes = fullTime.split(":")[1];
        double mD = Double.parseDouble(minutes);
        Double sD = Double.parseDouble(seconds);
        if (mD>0 & sD<60){
            sD+=60;
        }
        Double ffmpegPercentage = sD/duration;
        if (ffmpegPercentage>(double)1){
            ffmpegPercentage = (double)1;
        }
        int broadcastPercentage = 30 + (int)(ffmpegPercentage*70);
        /*during the initial creation of the mp4 video from png image, the time stays at zero
        * only when the video is muxed with the audio does the time update
        * so this increase allows the status broadcasts to keep from remaining stagnant*/
        if (broadcastPercentage==percentage | broadcastPercentage<percentage){
            broadcastPercentage = percentage+1;
        }

        //broadcast
        final int percentage_thread = broadcastPercentage;
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent("videoCreationStatus");
                intent.putExtra("percentage", percentage_thread);
                LocalBroadcastManager.getInstance(currentContext).sendBroadcast(intent);
            }
        });

        //update the container
        percentage = broadcastPercentage;
    }

//        Log.d("VideoCreator", "broadcastEncodingStatus: "+s);
}
```
And it is called via C->java JNI in the native-lib.c file (which is a little tricky).  You'll notice that in order to call java methods from C, you'll have to use the "GetMethodID" interface using "broadcastEncodingStatus" as the ID (the actual name of the java method).  The char that the custom ffmpeg method spits out is coverted to a jstring and the "(Ljava/lang/String;)V" string tells the JNI that method we are searching for returns void with String input.  I then set up a broadcast receiver to catch status updates in whatever Activity I want.

```C
JavaVM* javaVM = NULL;
jclass activityClass;
jobject activityObj;
void broadcastStatus(char *status){
    JNIEnv *env;
    (*javaVM)->AttachCurrentThread(javaVM, &env, NULL);
    jstring jstringStatus = (*env)->NewStringUTF(env, status);
    jmethodID method = (*env)->GetMethodID(env, activityClass, "broadcastEncodingStatus", "(Ljava/lang/String;)V");
    (*env)->CallVoidMethod(env, activityObj, method, jstringStatus);
}
```

## ffmpeg source code modifications
First off, if you look in the app/src/main/cpp/ffmpeg folder, you'll see that the main source files are located under a build_noConfig folder.  Each ABI has a specific config file which is placed in its respective folder that the CMake file maps out.  Otherwise, the source code is the same for each ABI.  I added a Logger.h header for logging and if you search for "Talkboy" in the following files, you will see my main changes/additions:

- ffmpeg.c (changed main() to main_ffmpeg(), added kill_program() method)
- ffmpeg.h
- cmdutils.c (removed program_exit() and exit() as this will kill the app - only happens if exception)
- libavutil/log.c (logging and status updates)

## Conclusion
There is a LOT going on here.  I'm sure I've missed a few things or can expand on some steps, so please let me know if there are any questions and I'll do my best to recall these exciting times.

C.J.
