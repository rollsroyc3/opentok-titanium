package com.tokbox.ti.opentok;

import java.util.Date;

import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;

import com.opentok.android.Connection;

@Kroll.proxy()
public class ConnectionProxy extends KrollProxy {

	Connection connection = null;
	
	public ConnectionProxy(Connection connection) {
		super();
		this.connection = connection;
	}
	
	public Connection getConnection() {
		return this.connection;
	}
	
	@Kroll.getProperty @Kroll.method
	public String getConnectionId() {
		return connection != null ? connection.getConnectionId() : null;
	}
	
	@Kroll.getProperty @Kroll.method
	public Date getCreationTime() {
		return connection != null ? connection.getCreationTime() : null;
	}
}
