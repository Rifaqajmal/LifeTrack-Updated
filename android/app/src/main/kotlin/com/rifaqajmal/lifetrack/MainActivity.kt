package com.rifaqajmal.lifetrack

import io.flutter.embedding.android.FlutterFragmentActivity

// local_auth (biometric app lock) requires a FragmentActivity, not a plain
// FlutterActivity. With FlutterActivity the biometric prompt can never show.
class MainActivity : FlutterFragmentActivity()
