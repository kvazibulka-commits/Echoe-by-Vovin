package ru.echoes.echoes

import android.content.ComponentName
import android.content.Intent
import android.media.MediaMetadata
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "echoes/np")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isEnabled" -> result.success(isEnabled())
                    "openSettings" -> {
                        startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                        result.success(null)
                    }
                    "current" -> result.success(current())
                    else -> result.notImplemented()
                }
            }
    }

    private fun isEnabled(): Boolean =
        Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
            ?.contains(packageName) == true

    private fun current(): Map<String, String>? {
        if (!isEnabled()) return null
        return try {
            val msm = getSystemService(MEDIA_SESSION_SERVICE) as MediaSessionManager
            val sessions = msm.getActiveSessions(ComponentName(this, NowPlayingService::class.java))
            val c = sessions.firstOrNull { it.playbackState?.state == PlaybackState.STATE_PLAYING }
                ?: return null
            val m = c.metadata ?: return null
            val title = m.getString(MediaMetadata.METADATA_KEY_TITLE) ?: return null
            mapOf(
                "title" to title,
                "artist" to (m.getString(MediaMetadata.METADATA_KEY_ARTIST) ?: ""),
                "app" to c.packageName
            )
        } catch (e: SecurityException) {
            null
        }
    }
}
