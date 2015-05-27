package com.tokbox.ti.opentok;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;

import com.opentok.android.OpentokError;
import com.opentok.android.Subscriber;
import com.opentok.android.SubscriberKit;

@Kroll.proxy()
public class SubscriberProxy extends KrollProxy implements Subscriber.SubscriberListener {
	Subscriber subscriber = null;
	SessionProxy sessionProxy = null;
	StreamProxy streamProxy = null;
	OpentokViewProxy view = null;
	
	public SubscriberProxy(Subscriber subscriber, SessionProxy sessionProxy, StreamProxy streamProxy) {
		super();
		this.sessionProxy = sessionProxy;
		this.streamProxy = streamProxy;
		this.subscriber = subscriber;
		this.subscriber.setSubscriberListener(SubscriberProxy.this);
	}
	
	@Kroll.getProperty @Kroll.method
	public SessionProxy getSession() {
		return sessionProxy;
	}
	
	@Kroll.getProperty @Kroll.method
	public StreamProxy getStream() {
		return streamProxy;
	}
	
	@Kroll.getProperty @Kroll.method
	public boolean getSubscribeToAudio() {
		return subscriber != null ? subscriber.getSubscribeToAudio() : false;
	}
	
	@Kroll.getProperty @Kroll.method
	public boolean getSubscribeToVideo() {
		return subscriber != null ? subscriber.getSubscribeToVideo() : false;
	}
	
	@Kroll.setProperty @Kroll.method
	public void setSubscribeToAudio(boolean response) {
		if (subscriber != null) {
			subscriber.setSubscribeToAudio(response);
		}
	}
	
	@Kroll.setProperty @Kroll.method
	public void setSubscribeToVideo(boolean response) {
		if (subscriber != null) {
			subscriber.setSubscribeToVideo(response);
		}
	}
	
	@Kroll.getProperty @Kroll.method
	public OpentokViewProxy getView() {
		return view;
	}
	
	@Kroll.method
	public OpentokViewProxy createView(KrollDict options) {
		view = new OpentokViewProxy();
		view.handleCreationDict(options);
		view.setAndroidView(subscriber.getView());
		return view;
	}

	@Override
	public void onConnected(SubscriberKit subscriber) {
		EventHelper.Trace("AndroidOpentok SubscriberProxy onConnected", "We fired the event for a subscriber connecting");
		KrollDict kd = new KrollDict();
		kd.put("subscriber", this);
		this.fireEvent("subscriberConnected", kd);
	}
	
	@Override
	public void onDisconnected(SubscriberKit subscriber) {
		EventHelper.Trace("AndroidOpentok SubscriberProxy onDisconnected", "We fired the event for a subscriber disconnecting");
		KrollDict kd = new KrollDict();
		kd.put("subscriber", this);
		this.fireEvent("subscriberDisconnected", kd);
	}

	@Override
	public void onError(SubscriberKit subscriber, OpentokError e) {
		EventHelper.Error("AndroidOpentok SubscriberProxy onSubscriberException", e.getMessage());
		subscriber = null;
		KrollDict kd = new KrollDict();
		kd.put("subscriber", this);
		this.fireEvent("subscriberFailed", kd);
	}
}
