package com.tokbox.ti.opentok;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiContext;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.view.TiUIView;

import android.app.Activity;
import android.view.View;

@Kroll.proxy()
public class OpentokViewProxy extends TiViewProxy {
	View androidView;
	
	public OpentokViewProxy() {
		super();
	}
	
	public OpentokViewProxy(TiContext tiContext) {
		this();
	}

	@Override
	public TiUIView createView(Activity activity) {
		OpentokView view = new OpentokView(this, androidView);
		view.getLayoutParams().autoFillsHeight = true;
		view.getLayoutParams().autoFillsWidth = true;
		EventHelper.Trace("OpentokAndroid ViewProxy createView", "have the view, returning it");
		return view;
	}
	
	public void setAndroidView(View androidView) {
		this.androidView = androidView;
	}
	
	// Handle creation options
	@Override
	public void handleCreationDict(KrollDict options) {
		super.handleCreationDict(options);
	}

	public void handleCreationArgs(KrollModule createdInModule, Object[] args) {
		super.handleCreationArgs(createdInModule, args);
	}

}
