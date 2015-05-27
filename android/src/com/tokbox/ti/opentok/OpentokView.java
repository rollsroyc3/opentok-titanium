package com.tokbox.ti.opentok;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.view.TiCompositeLayout;
import org.appcelerator.titanium.view.TiUIView;

import android.view.View;

public class OpentokView extends TiUIView {

	private TiCompositeLayout overlayLayout;
	
	public OpentokView(TiViewProxy proxy, View androidView) {
		super(proxy);
		
		try {
			if (androidView != null) {
				EventHelper.Trace("OpentokView", "androidView is not null. Trying to set the native view");
				setNativeView(androidView);
				EventHelper.Trace("AndroidOpentok View", "Set the native view and camera started.");
			} else {
				EventHelper.Error("AndroidOpentok View", "androidView came back null, bro.");
			}			
		} catch (Exception e) {
			EventHelper.Error("AndroidOpentok View", "Hit exception setting native view : " + e.getLocalizedMessage());
		}
	}
	
	@Override
	public void add(TiUIView overlayItem) {
		EventHelper.Trace("AndroidOpentok add", "Adding the overlay item to the view");
		if (overlayItem != null) {
			View overlayItemView = overlayItem.getNativeView();
			if (overlayItemView != null && overlayLayout != null) {
				overlayLayout.addView(overlayItemView,
						overlayItem.getLayoutParams());
			}
		}
	}

	@Override
	public void processProperties(KrollDict props) {
		EventHelper.Trace("AndroidOpentok processProperties", "processProperties called.");
		super.processProperties(props);
	}

	@Override
	public void propertyChanged(String key, Object oldValue, Object newValue, KrollProxy proxy) {
		EventHelper.Trace("AndroidOpentok propertyChanged", "property changed. updating");
		// This method is called whenever a proxy property value is updated.
		// Note that this
		// method is only called if the new value is different than the current
		// value.

		super.propertyChanged(key, oldValue, newValue, proxy);
	}

}
