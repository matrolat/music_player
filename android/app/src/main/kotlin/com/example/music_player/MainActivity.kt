package com.example.music_player

import android.media.MediaMetadataRetriever
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "music_metadata"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getMetadata") {
                val path = call.argument<String>("path")
                if (path != null) {
                    val retriever = MediaMetadataRetriever()
                    try {
                        retriever.setDataSource(path)

                        val title = retriever.extractMetadata(
                            MediaMetadataRetriever.METADATA_KEY_TITLE
                        ) ?: ""

                        val artist = retriever.extractMetadata(
                            MediaMetadataRetriever.METADATA_KEY_ARTIST
                        ) ?: ""

                        result.success(
                            mapOf(
                                "title" to title,
                                "artist" to artist
                            )
                        )
                    } catch (e: Exception) {
                        result.success(mapOf("title" to "", "artist" to ""))
                    } finally {
                        retriever.release()
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "File path is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
