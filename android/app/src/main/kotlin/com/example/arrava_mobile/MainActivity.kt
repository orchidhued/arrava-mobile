package com.example.arrava_mobile

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingQrBytes: ByteArray? = null
    private var pendingQrResult: MethodChannel.Result? = null

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != 7301) return
        val reply = pendingQrResult
        val bytes = pendingQrBytes
        pendingQrResult = null
        pendingQrBytes = null
        val uri = data?.data
        if (resultCode != android.app.Activity.RESULT_OK || uri == null) {
            reply?.error("CANCELLED", "Penyimpanan dibatalkan", null)
            return
        }
        try {
            checkNotNull(bytes)
            val stream = contentResolver.openOutputStream(uri)
                ?: throw IllegalStateException("File tidak dapat dibuka")
            stream.use { it.write(bytes) }
            reply?.success(null)
        } catch (e: Exception) {
            reply?.error("SAVE_FAILED", e.localizedMessage, null)
        }
    }

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
                "saveQr" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    if (pendingQrResult != null) {
                        result.error("BUSY", "Penyimpanan QR sedang berlangsung", null)
                    } else if (bytes == null || bytes.isEmpty()) {
                        result.error("INVALID_QR", "Data QR tidak tersedia", null)
                    } else {
                        pendingQrBytes = bytes
                        pendingQrResult = result
                        try {
                            val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                                addCategory(Intent.CATEGORY_OPENABLE)
                                type = "image/png"
                                putExtra(Intent.EXTRA_TITLE, "ARRAVA-QR-Siswa.png")
                            }
                            @Suppress("DEPRECATION")
                            startActivityForResult(intent, 7301)
                        } catch (e: Exception) {
                            pendingQrBytes = null
                            pendingQrResult = null
                            result.error("SAVE_FAILED", e.localizedMessage, null)
                        }
                    }
                }
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
