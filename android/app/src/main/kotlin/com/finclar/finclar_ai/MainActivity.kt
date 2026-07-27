package com.finclar.finclar_ai

import android.os.Bundle
import com.google.firebase.Firebase
import com.google.firebase.appdistribution.InterruptionLevel
import com.google.firebase.appdistribution.appDistribution
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Persistent notification testers can tap from anywhere to submit feedback
        // (with a screenshot). No-ops in builds without the full App Distribution
        // SDK (debug, and any future Play build), so it only appears for testers.
        Firebase.appDistribution.showFeedbackNotification(
            "Spotted a bug or have an idea? Tap to send feedback with a screenshot.",
            InterruptionLevel.HIGH,
        )
    }
}
