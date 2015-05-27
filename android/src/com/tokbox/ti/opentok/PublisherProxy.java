package com.tokbox.ti.opentok;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;

import com.opentok.android.OpentokError;
import com.opentok.android.Publisher;

@Kroll.proxy()
public class PublisherProxy extends KrollProxy implements Publisher.CameraListener {
	
	Publisher publisher = null;
	OpentokViewProxy view = null;
	SessionProxy sessionProxy = null;

	public PublisherProxy(Publisher publisher, SessionProxy sessionProxy) {
		super();
		this.sessionProxy = sessionProxy;
		this.publisher = publisher;
		this.publisher.setCameraListener(PublisherProxy.this);
	}
	
	@Kroll.method
	public OpentokViewProxy createView(KrollDict options) {
		try {
			EventHelper.Trace("AndroidOpentok PublisherProxy createView", "Creating a new OpentokViewProxy");
			view = new OpentokViewProxy();
			view.handleCreationDict(options);
			if (publisher != null) {
				view.setAndroidView(publisher.getView());
			}
			return view;
		} catch (Exception e) {
			EventHelper.Error("AndroidOpentok PublisherProxy createView", "Hit an exception creating the view : " + e.getLocalizedMessage());
			return null;
		}
		
	}
	
	@Kroll.getProperty @Kroll.method
	public OpentokViewProxy getView() {
		return view;
	}
	
	@Kroll.getProperty @Kroll.method
	public int getCameraPosition() {
		return publisher != null ? publisher.getCameraId() : 0;
	}
	
	@Kroll.setProperty @Kroll.method
	public void setCameraPosition(String response) {
		int id = response.equals("cameraBack") ? 0 : 1;
		if (publisher != null) {
			publisher.setCameraId(id);
		}
	}
	
	@Kroll.getProperty @Kroll.method
	public String getName() {
		return publisher != null ? publisher.getName() : null;
	}
	
	@Kroll.getProperty @Kroll.method
	public boolean getPublishAudio() {
		return publisher != null ? publisher.getPublishAudio() : false;
	}
	
	@Kroll.setProperty @Kroll.method
	public void setPublishAudio(boolean response) {
		if (publisher != null) {
			publisher.setPublishAudio(response);
		}
	}
	
	@Kroll.getProperty @Kroll.method
	public boolean getPublishVideo() {
		return publisher != null ? publisher.getPublishVideo() : false;
	}
	
	@Kroll.setProperty @Kroll.method
	public void setPublishVideo(boolean response) {
		if (publisher != null) {
			publisher.setPublishVideo(response);
		}
	}
	
	@Kroll.getProperty @Kroll.method
	public SessionProxy getSession() {
		return sessionProxy;
	}

	@Override
	public void onCameraChanged(Publisher publisher, int id) {
		EventHelper.Trace("AndroidOpentok PublisherProxy onPublisherChangedCamera", "onPublisherChangedCamera event fired");
	}
	
	@Override
	public void onCameraError(Publisher publisher, OpentokError e) {
		EventHelper.Error("AndroidOpentok PublisherProxy onCameraError", e.getMessage());
	}
}
