package com.example.hobby_sphere                          // must match package + folders

import io.flutter.embedding.android.FlutterFragmentActivity // v2 embedding base (Stripe needs FragmentActivity)
import android.os.Bundle                                   // Android Bundle

class MainActivity : FlutterFragmentActivity() {           // extend FragmentActivity
  override fun onCreate(savedInstanceState: Bundle?) {     // lifecycle
    super.onCreate(savedInstanceState)                     // call parent
    // no GeneratedPluginRegistrant here (v1 only)
  }
}
