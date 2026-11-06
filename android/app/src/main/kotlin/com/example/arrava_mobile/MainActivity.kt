package com.example.arrava_mobile

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.arrava.app/launcher"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Daftarkan factory pemutar video in-app
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "com.arrava.app/video_player",
                NativeVideoPlayerFactory()
            )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openUrl" -> {
                    val url = call.argument<String>("url")
                    if (!url.isNullOrBlank()) {
                        try {
                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("LAUNCH_FAILED", e.localizedMessage, null)
                        }
                    } else {
                        result.error("INVALID_URL", "URL is empty or null", null)
                    }
                }
                "openPdf" -> {
                    val url = call.argument<String>("url")
                    if (!url.isNullOrBlank()) {
                        val uri = Uri.parse(url)
                        try {
                            // Coba buka dengan PDF viewer intent
                            val pdfIntent = Intent(Intent.ACTION_VIEW).apply {
                                setDataAndType(uri, "application/pdf")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            }
                            startActivity(pdfIntent)
                            result.success(true)
                        } catch (e: Exception) {
                            // Fallback jika tidak ada dedicated app PDF, buka di browser
                            try {
                                val browserIntent = Intent(Intent.ACTION_VIEW, uri).apply {
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                                startActivity(browserIntent)
                                result.success(true)
                            } catch (e2: Exception) {
                                result.error("LAUNCH_FAILED", e2.localizedMessage, null)
                            }
                        }
                    } else {
                        result.error("INVALID_URL", "URL is empty or null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
