//
//  ReactNativePayworks
//
//  Created by Peace Chen on 2/27/2018.
//  Copyright © 2018 OnceThere. All rights reserved.
//

package com.oncethere.reactnativepayworks;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;

import java.util.HashMap;
import java.util.Map;

public class ReactNativePayworksModule extends ReactContextBaseJavaModule {

  private static final String SOME_KEY = "MY_KEY";

  public ReactNativePayworksModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  public String getName() {
    return "PayworksNative";
  }

  @Override
  public Map<String, Object> getConstants() {
    final Map<String, Object> constants = new HashMap<>();
    // constants.put(SOME_KEY, 1);
    return constants;
  }

  @ReactMethod
  public void transaction(ReadableMap xactionParams, Promise promise) {
    //ToDo

    WritableMap result = Arguments.createMap();
    result.putString("status", "status string"); //ToDo
    result.putString("transaction", "transaction msg"); //ToDo
    result.putString("details", "details msg"); //ToDo
    promise.resolve(result);
  }

  public void submitSignature(Object signature, Promise promise) {
    //ToDo
  }

  @ReactMethod
  public void cancelSignature(Promise promise) {
    //ToDo
  }

  @ReactMethod
  public void abortTransaction(Promise promise) {
    //ToDo
  }

  @ReactMethod
  public void disconnect(Promise promise) {
    //ToDo

    WritableMap result = Arguments.createMap();
    result.putInt("MPAccessoryProcessDetailsState", 1); //ToDo
    promise.resolve(result);
  }
}
