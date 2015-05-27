package com.tokbox.ti.opentok;

import java.util.Date;

import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;

import com.opentok.android.Connection;
import com.opentok.android.Stream;

@Kroll.proxy()
public class StreamProxy extends KrollProxy {

	Stream stream = null;
	
	public StreamProxy(Stream stream) {
		super();
		this.stream = stream;
	}
	
	public Stream getStream() {
		return stream;
	}
	
	@Kroll.getProperty @Kroll.method
	public Date getCreationTime() {
		return stream != null ? stream.getCreationTime() : null;
	}
	
	@Kroll.getProperty @Kroll.method
	public String getStreamId() {
		return stream != null ? stream.getStreamId() : null;
	}
	
	@Kroll.getProperty @Kroll.method
	public ConnectionProxy getConnection() {
		Connection connection = null;
		
		if (stream != null) {
			connection = stream.getConnection();
		}
		return new ConnectionProxy(connection);
	}
	
	@Kroll.getProperty @Kroll.method
	public String getName() {
		return stream != null ? stream.getName() : null;
	}
	
	@Kroll.method
	public boolean hasAudio() {
		return stream != null ? stream.hasAudio() : false;
	}
	
	@Kroll.method
	public boolean hasVideo() {
		return stream != null ? stream.hasVideo() : false;
	}
}
