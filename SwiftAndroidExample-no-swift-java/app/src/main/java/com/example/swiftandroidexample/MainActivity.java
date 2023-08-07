package com.example.swiftandroidexample;

import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;


public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        try {
            // initializing swift runtime.
            // The first argument is a pointer to java context (activity in this case).
            // The second argument should always be false.
            org.swift.swiftfoundation.SwiftFoundation.Initialize(this, false);
        } catch (Exception err) {
            android.util.Log.e("SwiftAndroidExample", "Can't initialize swift foundation: " + err.toString());
        }

        // loading dynamic library containing swift code
        System.loadLibrary("SwiftAndroidExample");

        // starting loading of data
        loadData("https://www.googleapis.com/books/v1/volumes?q=aaa");
    }

    public void onDataLoaded(String data) {
        android.util.Log.i("SwiftAndroidExample", "LOADED DATA: " + data);
    }

    private native void loadData(String url);
}