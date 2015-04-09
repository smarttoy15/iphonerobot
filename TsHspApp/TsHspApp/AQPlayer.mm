/*
 
    File: AQPlayer.mm
Abstract: n/a
 Version: 2.5

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2012 Apple Inc. All Rights Reserved.

 
*/


#include "AQPlayer.h"
#include <Foundation/NSString.h>
#include <Foundation/NSURL.h>  
#import <Foundation/Foundation.h>
#include <string.h>

class CAX4CCString {
public:
    CAX4CCString(OSStatus error) {
        // see if it appears to be a 4-char-code
        char *str = mStr;
        *(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
        if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
            str[0] = str[5] = '\'';
            str[6] = '\0';
        } else if (error > -200000 && error < 200000)
            // no, format it as an integer
            sprintf(str, "%d", (int)error);
        else
            sprintf(str, "0x%x", (int)error);
    }
    const char *get() const { return mStr; }
    operator const char *() const { return mStr; }
private:
    char mStr[16];
};

// An extended exception class that includes the name of the failed operation
class CAXException {
public:
    CAXException(const char *operation, OSStatus err) :
    mError(err)
    {
        if (operation == NULL)
            mOperation[0] = '\0';
        else if (strlen(operation) >= sizeof(mOperation)) {
            memcpy(mOperation, operation, sizeof(mOperation) - 1);
            mOperation[sizeof(mOperation) - 1] = '\0';
        } else
            
            strlcpy(mOperation, operation, sizeof(mOperation));
    }
    
    char *FormatError(char *str) const
    {
        return FormatError(str, mError);
    }
    
    char				mOperation[256];
    const OSStatus		mError;
    
    // -------------------------------------------------
    
    typedef void (*WarningHandler)(const char *msg, OSStatus err);
    
    static char *FormatError(char *str, OSStatus error)
    {
        strcpy(str, CAX4CCString(error));
        return str;
    }
    
    static void Warning(const char *s, OSStatus error)
    {
        if (sWarningHandler)
            (*sWarningHandler)(s, error);
    }
    
    static void SetWarningHandler(WarningHandler f) { sWarningHandler = f; }
private:
    static WarningHandler	sWarningHandler;
};

#define XThrowIfError(error, operation)										\
    do {																	\
        OSStatus __err = error;												\
        if (__err) {														\
            throw CAXException(operation, __err);							\
        }																	\
    } while (0)

#define kBufferDurationSeconds 0.5

#pragma mark temp file;

void AQPlayer::writeWaveHead(NSData *audioData, NSString* wavFile) {
    Byte waveHead[44];
    waveHead[0] = 'R';
    waveHead[1] = 'I';
    waveHead[2] = 'F';
    waveHead[3] = 'F';
    
    long totalDatalength = [audioData length] + 44;
    waveHead[4] = (Byte)(totalDatalength & 0xff);
    waveHead[5] = (Byte)((totalDatalength >> 8) & 0xff);
    waveHead[6] = (Byte)((totalDatalength >> 16) & 0xff);
    waveHead[7] = (Byte)((totalDatalength >> 24) & 0xff);
    
    waveHead[8] = 'W';
    waveHead[9] = 'A';
    waveHead[10] = 'V';
    waveHead[11] = 'E';
    
    waveHead[12] = 'f';
    waveHead[13] = 'm';
    waveHead[14] = 't';
    waveHead[15] = ' ';
    
    waveHead[16] = 16;  //size of 'fmt '
    waveHead[17] = 0;
    waveHead[18] = 0;
    waveHead[19] = 0;
    
    waveHead[20] = 1;   //format
    waveHead[21] = 0;
    
    waveHead[22] = 1;   //chanel
    waveHead[23] = 0;
    
    long sampleRate = 16000;
    waveHead[24] = (Byte)(sampleRate & 0xff);
    waveHead[25] = (Byte)((sampleRate >> 8) & 0xff);
    waveHead[26] = (Byte)((sampleRate >> 16) & 0xff);
    waveHead[27] = (Byte)((sampleRate >> 24) & 0xff);
    
    long byteRate = 16000 * 2 * (16 >> 3);;
    waveHead[28] = (Byte)(byteRate & 0xff);
    waveHead[29] = (Byte)((byteRate >> 8) & 0xff);
    waveHead[30] = (Byte)((byteRate >> 16) & 0xff);
    waveHead[31] = (Byte)((byteRate >> 24) & 0xff);
    
    waveHead[32] = 2*(16 >> 3);
    waveHead[33] = 0;
    
    waveHead[34] = 16;
    waveHead[35] = 0;
    
    waveHead[36] = 'd';
    waveHead[37] = 'a';
    waveHead[38] = 't';
    waveHead[39] = 'a';
    
    long totalAudiolength = [audioData length];
    
    waveHead[40] = (Byte)(totalAudiolength & 0xff);
    waveHead[41] = (Byte)((totalAudiolength >> 8) & 0xff);
    waveHead[42] = (Byte)((totalAudiolength >> 16) & 0xff);
    waveHead[43] = (Byte)((totalAudiolength >> 24) & 0xff);
    
    NSMutableData *pcmData = [[NSMutableData alloc]initWithBytes:&waveHead length:sizeof(waveHead)];
    [pcmData appendData:audioData];

    [pcmData writeToFile:wavFile atomically:YES];
}

void AQPlayer::transformFile(NSString* pcmFile, NSString* wavFile) {
    NSData* audioData = [NSData dataWithContentsOfFile:pcmFile];
    writeWaveHead(audioData, wavFile);
}

void AQPlayer::AQBufferCallback(void *					inUserData,
								AudioQueueRef			inAQ,
								AudioQueueBufferRef		inCompleteAQBuffer) 
{
	AQPlayer *THIS = (AQPlayer *)inUserData;

	if (THIS->mIsDone) return;

	UInt32 numBytes;
	UInt32 nPackets = THIS->GetNumPacketsToRead();
	OSStatus result = AudioFileReadPackets(THIS->GetAudioFileID(), false, &numBytes, inCompleteAQBuffer->mPacketDescriptions, THIS->GetCurrentPacket(), &nPackets, 
										   inCompleteAQBuffer->mAudioData);
	if (result)
		printf("AudioFileReadPackets failed: %d", (int)result);
	if (nPackets > 0) {
		inCompleteAQBuffer->mAudioDataByteSize = numBytes;		
		inCompleteAQBuffer->mPacketDescriptionCount = nPackets;		
		AudioQueueEnqueueBuffer(inAQ, inCompleteAQBuffer, 0, NULL);
		THIS->mCurrentPacket = (THIS->GetCurrentPacket() + nPackets);
	} 
	
	else 
	{
		if (THIS->IsLooping())
		{
			THIS->mCurrentPacket = 0;
			AQBufferCallback(inUserData, inAQ, inCompleteAQBuffer);
		}
		else
		{
			// stop
			THIS->mIsDone = true;
			AudioQueueStop(inAQ, false);
		}
	}
}

void AQPlayer::isRunningProc (  void *              inUserData,
								AudioQueueRef           inAQ,
								AudioQueuePropertyID    inID)
{
	AQPlayer *THIS = (AQPlayer *)inUserData;
	UInt32 size = sizeof(THIS->mIsRunning);
	OSStatus result = AudioQueueGetProperty (inAQ, kAudioQueueProperty_IsRunning, &THIS->mIsRunning, &size);
    if ((result == noErr) && (!THIS->mIsRunning)) {
        NSLog(@"AQPlayer is running proc .............................");
    }
//	if ((result == noErr) && (!THIS->mIsRunning))
//		[[NSNotificationCenter defaultCenter] postNotificationName: @"playbackQueueStopped" object: nil];
}

void AQPlayer::CalculateBytesForTime (AudioStreamBasicDescription & inDesc, UInt32 inMaxPacketSize, Float64 inSeconds, UInt32 *outBufferSize, UInt32 *outNumPackets)
{
	// we only use time here as a guideline
	// we're really trying to get somewhere between 16K and 64K buffers, but not allocate too much if we don't need it
	static const int maxBufferSize = 0x10000; // limit size to 64K
	static const int minBufferSize = 0x4000; // limit size to 16K
	
	if (inDesc.mFramesPerPacket) {
		Float64 numPacketsForTime = inDesc.mSampleRate / inDesc.mFramesPerPacket * inSeconds;
		*outBufferSize = numPacketsForTime * inMaxPacketSize;
	} else {
		// if frames per packet is zero, then the codec has no predictable packet == time
		// so we can't tailor this (we don't know how many Packets represent a time period
		// we'll just return a default buffer size
		*outBufferSize = maxBufferSize > inMaxPacketSize ? maxBufferSize : inMaxPacketSize;
	}
	
	// we're going to limit our size to our default
	if (*outBufferSize > maxBufferSize && *outBufferSize > inMaxPacketSize)
		*outBufferSize = maxBufferSize;
	else {
		// also make sure we're not too small - we don't want to go the disk for too small chunks
		if (*outBufferSize < minBufferSize)
			*outBufferSize = minBufferSize;
	}
	*outNumPackets = *outBufferSize / inMaxPacketSize;
}

AQPlayer::AQPlayer() :
	mQueue(0),
	mAudioFile(0),
	mFilePath(NULL),
	mIsRunning(false),
	mIsInitialized(false),
	mNumPacketsToRead(0),
	mCurrentPacket(0),
	mIsDone(false),
	mIsLooping(false) { }

AQPlayer::~AQPlayer() 
{
	DisposeQueue(true);
}

OSStatus AQPlayer::StartQueue(BOOL inResume)
{	
	// if we have a file but no queue, create one now
	if ((mQueue == NULL) && (mFilePath != NULL)) CreateQueueForFile((__bridge NSString*)mFilePath);
	
	mIsDone = false;
	
	// if we are not resuming, we also should restart the file read index
	if (!inResume) {
		mCurrentPacket = 0;

        // prime the queue with some data before starting
        for (int i = 0; i < kNumberBuffers; ++i) {
            AQBufferCallback (this, mQueue, mBuffers[i]);			
        }
    }
	return AudioQueueStart(mQueue, NULL);
}

OSStatus AQPlayer::StopQueue()
{
    mIsDone = true;
    
	OSStatus result = AudioQueueStop(mQueue, true);
	if (result) printf("ERROR STOPPING QUEUE!\n");

	return result;
}

OSStatus AQPlayer::PauseQueue()
{
	OSStatus result = AudioQueuePause(mQueue);

	return result;
}

void AQPlayer::CreateQueueForFile(NSString* inFilePath)
{	
	CFURLRef sndFile = NULL; 

	try {
		if (mFilePath == NULL)
		{
			mIsLooping = false;
            
            const char *ptr = [inFilePath cStringUsingEncoding:NSASCIIStringEncoding];
            sndFile = CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8*)ptr, strlen(ptr), false);
            if (!sndFile) { printf("can't parse file path %@\n", inFilePath); return; }
        
//			sndFile = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, inFilePath, kCFURLPOSIXPathStyle, false);
//			if (!sndFile) { printf("can't parse file path\n"); return; }
			
            OSStatus rc = AudioFileOpenURL (sndFile, kAudioFileReadWritePermission, 0/*inFileTypeHint*/, &mAudioFile);
            CFRelease(sndFile); // release sndFile here to quiet analyzer
			XThrowIfError(rc, "can't open file");
             
			UInt32 size = sizeof(mDataFormat);
			XThrowIfError(AudioFileGetProperty(mAudioFile, kAudioFilePropertyDataFormat, &size, &mDataFormat), "couldn't get file's data format");
            mFilePath = CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)inFilePath);
		}
		SetupNewQueue();		
    }
	catch (CAXException e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
	}
}

void AQPlayer::SetupNewQueue() 
{
	XThrowIfError(AudioQueueNewOutput(&mDataFormat, AQPlayer::AQBufferCallback, this, 
										CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &mQueue), "AudioQueueNew failed");
	UInt32 bufferByteSize;		
	// we need to calculate how many packets we read at a time, and how big a buffer we need
	// we base this on the size of the packets in the file and an approximate duration for each buffer
	// first check to see what the max size of a packet is - if it is bigger
	// than our allocation default size, that needs to become larger
	UInt32 maxPacketSize;
	UInt32 size = sizeof(maxPacketSize);
	XThrowIfError(AudioFileGetProperty(mAudioFile, 
									   kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize), "couldn't get file's max packet size");
	
	// adjust buffer size to represent about a half second of audio based on this format
	CalculateBytesForTime (mDataFormat, maxPacketSize, kBufferDurationSeconds, &bufferByteSize, &mNumPacketsToRead);

		//printf ("Buffer Byte Size: %d, Num Packets to Read: %d\n", (int)bufferByteSize, (int)mNumPacketsToRead);
	
	// (2) If the file has a cookie, we should get it and set it on the AQ
	size = sizeof(UInt32);
	OSStatus result = AudioFileGetPropertyInfo (mAudioFile, kAudioFilePropertyMagicCookieData, &size, NULL);
	
	if (!result && size) {
		char* cookie = new char [size];		
		XThrowIfError (AudioFileGetProperty (mAudioFile, kAudioFilePropertyMagicCookieData, &size, cookie), "get cookie from file");
		XThrowIfError (AudioQueueSetProperty(mQueue, kAudioQueueProperty_MagicCookie, cookie, size), "set cookie on queue");
		delete [] cookie;
	}
	
	// channel layout?
	result = AudioFileGetPropertyInfo(mAudioFile, kAudioFilePropertyChannelLayout, &size, NULL);
	if (result == noErr && size > 0) {
		AudioChannelLayout *acl = (AudioChannelLayout *)malloc(size);
        
        result = AudioFileGetProperty(mAudioFile, kAudioFilePropertyChannelLayout, &size, acl);
        if (result) { free(acl); XThrowIfError(result, "get audio file's channel layout"); }
        
        result = AudioQueueSetProperty(mQueue, kAudioQueueProperty_ChannelLayout, acl, size);
        if (result){ free(acl); XThrowIfError(result, "set channel layout on queue"); }
		
        free(acl);
    }
	
	XThrowIfError(AudioQueueAddPropertyListener(mQueue, kAudioQueueProperty_IsRunning, isRunningProc, this), "adding property listener");
	
	bool isFormatVBR = (mDataFormat.mBytesPerPacket == 0 || mDataFormat.mFramesPerPacket == 0);
	for (int i = 0; i < kNumberBuffers; ++i) {
		XThrowIfError(AudioQueueAllocateBufferWithPacketDescriptions(mQueue, bufferByteSize, (isFormatVBR ? mNumPacketsToRead : 0), &mBuffers[i]), "AudioQueueAllocateBuffer failed");
	}	

	// set the volume of the queue
	XThrowIfError (AudioQueueSetParameter(mQueue, kAudioQueueParam_Volume, 1.0), "set queue volume");
	
	mIsInitialized = true;
}

void AQPlayer::DisposeQueue(Boolean inDisposeFile)
{
	if (mQueue)
	{
		AudioQueueDispose(mQueue, true);
		mQueue = NULL;
	}
	if (inDisposeFile)
	{
		if (mAudioFile)
		{		
			AudioFileClose(mAudioFile);
			mAudioFile = 0;
		}
		if (mFilePath)
		{
			CFRelease(mFilePath);
			mFilePath = NULL;
		}
	}
	mIsInitialized = false;
}