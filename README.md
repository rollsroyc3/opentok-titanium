# opentok-titanium-mobile

A module for the Titanium Mobile platform that uses the Opentok iOS and Android SDKs for video streaming.

## Background Information

This module was originally created by Ankur Oberoi, a member of the Opentok team. He did all the hard work creating the iOS module, but he's been unable to maintain it over the last couple years, and his original work is very outdated and no longer works. This fork gets it working with the latest version of the Opentok iOS SDK, and also adds support for Android using the latest Android SDK.

The Android module is something I wrote when I was a fairly new developer, and while it works fine, it could probably stand to be refactored in some areas. I attempted to get its functionality as close to the iOS module as possible, but there are a couple areas where you'll need to make platform specific calls.

The iOS module is something I've just hacked together to work with the newer versions of Opentok and Titanium. I have zero Objective-C experience outside of tinkering with this, and I have no desire to learn it. As such, the iOS module is a bit of a mess, and could definitely stand to be refactored if anyone with more Objective-C experience wants to tackle it.

Since I actively maintain a Titanium application that uses this module, I will continue to update it as new versions of Titanium and Opentok call for it. But again, my main focus is just to keep it working at this point, not to make it a paragon of clean code and best practices. If anyone wants to actively contribute and improve upon it, please do.

## Installation

#### iOS

1. Despite having multiple examples, I couldn't ever get it to work such that I could pass the Opentok API key from Titanium JavaScript to the Opentok iOS module (I'm sure it's something trivial, but I haven't felt like revisiting it). As such, `ComTokboxTiOpentokSessionProxy.m` needs to be updated with your API key. Do a search for `YOUR_API_KEY_HERE`, and replace it in two spots. If this issue can get resolved, I'll create a distribution archive for those who aren't up for building this themselves.
2. Download the latest [Opentok iOS SDK](https://tokbox.com/opentok/libraries/client/ios/) (2.5.0 as of this writing) and include `OpenTok.framework` in the root folder.
3. If you do not have Titanium SDK 3.5.1, open `titanium.xcconfig` and change 3.5.1 to the version you have. You probably need to at least build with 3.5.0 though, since that's when the x64 stuff happened.
4. Run `./build.py` from the terminal.
5. Extract the archive to your Titanium project's modules folder.
6. Add the module in your Titanium project's tiapp.xml file.

#### Android

1. Download the latest [Opentok Android SDK](https://tokbox.com/opentok/libraries/client/android/) (2.5.0 as of this writing), and copy the libs folder to your root directory. Move `opentok-android-sdk-2.5.0.jar` to the lib folder, and create a new folder called `armeabi-v7a` in the `libs` folder. Copy the contents of `armeabi` into `armeabi-v7a`.
2. Open `build.properties` and update the paths to wherever you have those things installed to. You may also need to change the Android SDK version, Titanium version, and Android NDK version, depending on what you have installed.
3. Run `ant` from the terminal.
4. Extract the archive to your Titanium project's modules folder.
5. Add the module in your Titanium project's tiapp.xml file.

## Basic Usage

```javascript

var opentok = require('com.tokbox.ti.opentok');
var sessionId;
var session;
var token;
var session;
var publisher;

function getSessionInfo() {
	// get session from your server
}

function createOpentokSession() {
	session = opentok.createSession({
		sessionId: sessionId,
		apiKey: 'YOUR_API_KEY' // works on Android but not iOS. If someone can fix that'd be great.
	});
	connectSession(session);
}

function disconnectOpentokSession() {
	if (session) {
		session.disconnect();
		session = null;
	}
}

function connectSession(opentokSession) {
	if (opentokFailed) return;
	session = opentokSession;
	if (session) {
		session.addEventListener('sessionConnected', sessionConnected);
		session.addEventListener('sessionDisconnected', sessionDisconnected);
		session.addEventListener('sessionFailed', sessionFailed);
		session.addEventListener('streamCreated', streamCreated);
		session.addEventListener('streamDestroyed', streamDestroyed);
		
		session.connect('YOUR_API_KEY', token);
	}
}

function sessionConnected() {
	if (Alloy.CFG.IOS) {
		Ti.Media.setAudioSessionCategory(Ti.Media.AUDIO_SESSION_CATEGORY_PLAY_AND_RECORD); // when done set back to Ti.Media.AUDIO_SESSION_CATEGORY_PLAYBACK
	}
	
	if (Ti.Platform.model != 'Simulator' && !publisherView) {
		publisher = session.publish();
		publisher.cameraPosition = 'cameraBack';
		publisherView = publisher.createView({
			width : Ti.UI.FILL,
			height : Ti.UI.FILL,
			center : 0
		});
		$.videoView.add(publisherView);
		if (Alloy.CFG.Android) {
			session.connectPublisher();
		}
	}
}

function sessionDisconnected() {
	alert('opentok disconnected');
}

function sessionFailed() {
	alert('The session failed. Please try again later.');
}

function streamDestroyed(e) {
	if (e && e.stream) {
		var stream = e.stream;
	}
	
	if (stream && session && stream.connection.connectionId != session.connection.connectionId) {
		if ($.videoView && subscriberView) {
			$.videoView.remove(subscriberView);
			subscriberView = null;
		}
	}
}

function streamCreated(e) {
	var stream = e.stream;
	if (stream.connection.connectionId === session.connection.connectionId) {
		return;
	}
	
	if (!subscriberView) {
		var subscriber = session.subscribe(stream);
		subscriberView = subscriber.createView({
			width : '400px',
			height : '300px',
			left : 0,
			bottom: 0
		});
		if (subscriberView) $.videoView.add(subscriberView);
		if (Alloy.CFG.Android) {
			session.connectSubscriber();
		}
	}
}

```

## License

Copyright (c) 2012 TokBox, Inc.
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

The software complies with Terms of Service for the OpenTok platform described 
in http://www.tokbox.com/termsofservice

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.

