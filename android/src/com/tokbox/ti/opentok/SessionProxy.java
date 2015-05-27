package com.tokbox.ti.opentok;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiApplication;

import android.app.Activity;

import com.opentok.android.Connection;
import com.opentok.android.OpentokError;
import com.opentok.android.Publisher;
import com.opentok.android.Session;
import com.opentok.android.Stream;
import com.opentok.android.Subscriber;

@Kroll.proxy(creatableInModule = OpentokModule.class)
public class SessionProxy extends KrollProxy implements Session.SessionListener {
	
	private Session session = null;
	String sessionConnectionStatus = "disconnected";
	Publisher publisher = null;
	Subscriber subscriber = null;
	TiApplication appContext = TiApplication.getInstance();
	Activity activity = appContext.getCurrentActivity();
	
	public SessionProxy() {
		super();
	}
	
	@Kroll.method
	public PublisherProxy publish() {
		try {
			EventHelper.Trace("OpentokAndroid SessionProxy publish", "Publishing a stream.");
			
			publisher = new Publisher(activity);
			PublisherProxy publisherProxy = new PublisherProxy(publisher, this);
			
			return publisherProxy;
		} catch (Exception e) {
			EventHelper.Error("OpentokAndroid SessionProxy publish", "Exception publishing : " + e.getLocalizedMessage());
			return null;
		}
		
	}
	
	@Kroll.method
	public void connectPublisher() {
		try {
			if (session != null && publisher != null) {
				session.publish(publisher);
			}
		} catch (Exception e) {
			EventHelper.Error("OpentokAndroid SessionProxy publish", "Exception connecting publisher : " + e.getLocalizedMessage());
		}
	}
	
	@Kroll.method
	public void connectSubscriber() {
		try {
			if (session != null && subscriber != null) {
				session.subscribe(subscriber);
			}
		} catch (Exception e) {
			EventHelper.Error("OpentokAndroid SessionProxy publish", "Exception connecting subscriber : " + e.getLocalizedMessage());
		}
	}
	
	@Kroll.method
	public SubscriberProxy subscribe(StreamProxy streamProxy) {
		EventHelper.Trace("OpentokAndroid SessionProxy subscribe", "Subscribing to a stream.");
		
		Stream stream = streamProxy.getStream();
		subscriber = new Subscriber(activity, stream);		
		SubscriberProxy subscriberProxy = new SubscriberProxy(subscriber, this, streamProxy);
		
		return subscriberProxy;
	}
	
	@Kroll.method
	public void connect(String apiKey, String token) {
		EventHelper.Trace("OpentokAndroid SessionProxy connect", "Connecting a session.");
		if (session != null) {
			try {
				session.connect(token);
			} catch(Exception e) {
				EventHelper.Error("OpentokAndroid SessionProxy connect", e.getLocalizedMessage());
			}
			
		}
	}
	
	@Kroll.method
	public void disconnect() {
		EventHelper.Trace("OpentokAndroid SessionProxy disconnect", "Disconnecting a session.");
		if (session != null) {
			try {
				session.disconnect();
				session = null;
			} catch (Exception e) {
				EventHelper.Error("OpentokAndroid SessionProxy disconnect", "Session disconnect exception : " + e.getLocalizedMessage());
			}
		}
	}
	
	@Kroll.method
	public void unpublish() {
		if (session != null && publisher != null) {
			session.unpublish(publisher);
			publisher = null;
		}
	}
	
	@Kroll.method
	public void unsubscribe() {
		if (session != null && subscriber != null) {
			session.unsubscribe(subscriber);
			subscriber = null;
		}
	}
	
	@Kroll.getProperty @Kroll.method
	public String getSessionId() {
		if (session != null) {
			return session.getSessionId();
		} else {
			return null;
		}
	}
	
	@Kroll.getProperty @Kroll.method
	public ConnectionProxy getConnection() {
		Connection connection = null;
		
		if (session != null) {
			connection = session.getConnection();
		}
		return new ConnectionProxy(connection);
	}
	
	@Kroll.getProperty @Kroll.method
	public String getSessionConnectionStatus() {
		return sessionConnectionStatus;
	}

	public Session getSession() {
		return session;
	}
	
	// Note that this is what is getting called in the Titanium javascript code at
	// opentok.createSession, because it's creating this session proxy.
	@Override
	public void handleCreationDict(KrollDict options) 
	{
		String sessionId = options.getString("sessionId");
		String apiKey = options.getString("apiKey");
		
		createSession(apiKey, sessionId);
		super.handleCreationDict(options);
	}
	
	private void createSession(String apiKey, String sessionId) {
		try {
			EventHelper.Error("createSession", "Creating Session");
			
			session = new Session(activity, apiKey, sessionId);
			EventHelper.Error("createSession", "Created Session");
			
			session.setSessionListener(SessionProxy.this);
			
		} catch(Exception e) {
			EventHelper.Error("OpentokAndroid SessionProxy createSession", "Hit the exception : " + e.getMessage());
		}
	}
	
	public void handleCreationArgs(KrollModule createdInModule, Object[] args) 
	{
		super.handleCreationArgs(createdInModule, args);
	}

	@Override
	public void onConnected(Session session) {
		sessionConnectionStatus = "connected";
		this.fireEvent("sessionConnected", null);
	}

	@Override
	public void onDisconnected(Session session) {
		sessionConnectionStatus = "disconnected";
		EventHelper.Trace("OpentokAndroid SessionProxy onSessionDisconnected", "Session disconnect event fired");
		this.fireEvent("sessionDisconnected", null);
	}
	
	@Override
	public void onStreamReceived(Session session, Stream stream) {
		EventHelper.Trace("OpentokAndroid SessionProxy onSessionDidReceiveStream", "Got a stream.");
		
		StreamProxy streamProxy = new StreamProxy(stream);
		KrollDict kd = new KrollDict();
		kd.put("stream", streamProxy);
		this.fireEvent("streamCreated", kd);
	}

	@Override
	public void onStreamDropped(Session session, Stream stream) {
		EventHelper.Error("OpentokAndroid SessionProxy onSessionDidDropStream", stream.getStreamId());
		StreamProxy streamProxy = new StreamProxy(stream);
		
		KrollDict kd = new KrollDict();
		kd.put("stream", streamProxy);
		this.fireEvent("streamDestroyed", kd);
	}

	@Override
	public void onError(Session session, OpentokError e) {
		sessionConnectionStatus = "disconnected";
		EventHelper.Error("OpentokAndroid SessionProxy onSessionException", e.getMessage());
		this.fireEvent("sessionFailed", e.getMessage());
	}
}
