// use FlutterFragmentActivity (required for 3DS / Google Pay)
package com.example.hobby_sphere  // update if your package is different

import io.flutter.embedding.android.FlutterFragmentActivity  // base activity
import android.os.Bundle                                     // bundle

class MainActivity : FlutterFragmentActivity() {             // extend fragment activity
  override fun onCreate(savedInstanceState: Bundle?) {       // lifecycle
    super.onCreate(savedInstanceState)                       // call parent
  }
}
