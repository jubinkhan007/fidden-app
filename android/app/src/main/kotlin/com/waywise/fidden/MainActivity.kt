package com.waywise.fidden

import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // ⬇️ critical so uni_links (and others) can read the latest deep link
        setIntent(intent)
    }
}
