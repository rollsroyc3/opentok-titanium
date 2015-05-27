package com.tokbox.ti.opentok;

import java.lang.Thread.UncaughtExceptionHandler;

import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiContext;

import android.app.Activity;

@Kroll.module(name = "Opentok", id = "com.tokbox.ti.opentok")
public class OpentokModule extends KrollModule {
	
	private UncaughtExceptionHandler defaultUEH;
	private static OpentokModule _THIS;

	@Kroll.method
	public void cleanup() {
	}
	
	public OpentokModule(TiContext tiContext) {
		super(tiContext);
		_THIS = this;
		
		defaultUEH = Thread.getDefaultUncaughtExceptionHandler();
		Thread.setDefaultUncaughtExceptionHandler(_unCaughtExceptionHandler);
	}

	public static OpentokModule getInstance() {
		return _THIS;
	}
	
	private Thread.UncaughtExceptionHandler _unCaughtExceptionHandler =
	        new Thread.UncaughtExceptionHandler() {
	            @Override
	            public void uncaughtException(Thread thread, Throwable ex) {

	            	
	            	
	            	//EventHelper.Error("UncaughtException", ex.getLocalizedMessage());
	                EventHelper.UncaughtException(ex.getLocalizedMessage());
            		
	                //defaultUEH.uncaughtException(thread, ex);
	                //System.exit(777);
	                
	            }
	        };
}
