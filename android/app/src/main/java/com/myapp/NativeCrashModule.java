package com.myapp;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

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


}
