package com.myapp;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

public class NativeCrashModule extends ReactContextBaseJavaModule {

    public NativeCrashModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "NativeCrash";
    }

    @ReactMethod
    public void tryCrash() {
        throw new RuntimeException("Try Crash");
    }

    @ReactMethod
    public void findEvents(Promise promise) {
        promise.reject("no_events", "There were no events", new RuntimeException("Native Promise Rejection"));
    }

}
