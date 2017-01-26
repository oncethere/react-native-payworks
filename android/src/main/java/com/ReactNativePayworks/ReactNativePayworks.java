package com.ReactNativePayworks;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.bridge.Callback;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.Cursor;
import android.util.Log;
import android.net.Uri;

import java.util.HashMap;
import java.util.Map;
import java.lang.Long;

public class ReactNativePayworks extends ReactContextBaseJavaModule {

  ReactApplicationContext reactContext;

  public ReactNativePayworks(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "ReactNativePayworks";
  }

  @ReactMethod
  public void transaction() {
    // ToDo: integrate Payworks Android library
  }

  @ReactMethod
  public void submitSignature() {
    // ToDo: integrate Payworks Android library
  }

}
