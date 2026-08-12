package com.finclar.finclar_ai

import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.os.Bundle
import com.google.firebase.Firebase
import com.google.firebase.appdistribution.InterruptionLevel
import com.google.firebase.appdistribution.appDistribution
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    companion object {
        // Must match the channel id in AndroidManifest.xml's
        // com.google.firebase.messaging.default_notification_channel_id meta-data.
        const val NOTIFICATION_CHANNEL_ID = "finclar_default_channel"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
        // Persistent notification testers can tap from anywhere to submit feedback
        // (with a screenshot). No-ops in builds without the full App Distribution
        // SDK (debug, and any future Play build), so it only appears for testers.
        Firebase.appDistribution.showFeedbackNotification(
            "Spotted a bug or have an idea? Tap to send feedback with a screenshot.",
            InterruptionLevel.HIGH,
        )
    }

    // Android binds notification sound to the channel at creation time and ignores
    // later changes, so the custom tone has to be set up here before any FCM
    // message can post to this channel.
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val soundUri = Uri.parse("android.resource://$packageName/${R.raw.notification_tone}")
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        val channel = NotificationChannel(
            NOTIFICATION_CHANNEL_ID,
            "Finclar Notifications",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Transaction alerts, budget warnings, group activity, and AI insights"
            setSound(soundUri, audioAttributes)
        }

        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(channel)
    }
}
