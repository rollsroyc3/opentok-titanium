package com.tokbox.ti.opentok;

import org.appcelerator.kroll.KrollDict;
import android.util.Log;

public class EventHelper {
	
	public static final String LCAT = "CaoOpentokModule";
	private final static boolean TRACE_EVENTS = true;
	private final static boolean ERROR_EVENTS = true;

	public static void Trace(String name, String value) {

		if (TRACE_EVENTS) {
			KrollDict kd = new KrollDict();
			kd.put("name", name);
			kd.put("value", value);
			OpentokModule.getInstance().fireEvent("trace", kd);
			Log.i(LCAT, name + " : " + value);
		}
	}

	public static void Error(String name, String value) {

		if (ERROR_EVENTS) {
			KrollDict kd = new KrollDict();
			kd.put("name", name);
			kd.put("value", value);
			// kd.put("errorCode", 1000);
			OpentokModule.getInstance().fireEvent("error", kd);
			Log.e(LCAT, name + " : " + value);
		}
	}
	
	public static void UncaughtException(String value) {

		KrollDict kd = new KrollDict();
		kd.put("name", "Uncaught Exception");
		kd.put("value", value);
		OpentokModule.getInstance().fireEvent("uncaughtException", kd);
	}
}
