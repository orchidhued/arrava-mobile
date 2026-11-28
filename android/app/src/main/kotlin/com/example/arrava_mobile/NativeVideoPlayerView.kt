package com.example.arrava_mobile

import android.content.Context
import android.graphics.Color
import android.net.Uri
import android.view.View
import android.view.ViewGroup
import android.webkit.WebChromeClient
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeVideoPlayerFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val creationParams = args as? Map<String, Any>
        return NativeVideoPlayerView(context, viewId, creationParams)
    }
}

class NativeVideoPlayerView(
    context: Context,
    id: Int,
    creationParams: Map<String, Any>?
) : PlatformView {
    private val webView: WebView = WebView(context)

    init {
        val videoUrl = creationParams?.get("videoUrl") as? String
        val youtubeId = creationParams?.get("youtubeId") as? String
        val isPdf = creationParams?.get("isPdf") as? Boolean ?: false

        webView.apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            setBackgroundColor(Color.BLACK)
            settings.apply {
                javaScriptEnabled = true
                domStorageEnabled = true
                mediaPlaybackRequiresUserGesture = false
                allowFileAccess = true
                allowContentAccess = true
                databaseEnabled = true
                cacheMode = WebSettings.LOAD_DEFAULT
                useWideViewPort = true
                loadWithOverviewMode = true
            }
            webChromeClient = WebChromeClient()
            webViewClient = object : WebViewClient() {
                override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                    // Biarkan video atau konten tetap dimuat di dalam aplikasi
                    return false
                }
            }
        }

        loadContent(youtubeId, videoUrl, isPdf)
    }

    private fun loadContent(youtubeId: String?, videoUrl: String?, isPdf: Boolean) {
        if (!youtubeId.isNullOrBlank()) {
            val html = """
                <!DOCTYPE html>
                <html>
                <head>
                    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                    <style>
                        * { margin: 0; padding: 0; box-sizing: border-box; }
                        html, body {
                            width: 100%;
                            height: 100%;
                            background-color: #000000;
                            overflow: hidden;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                        }
                        .video-wrapper {
                            position: relative;
                            width: 100%;
                            height: 100%;
                        }
                        #player {
                            width: 100%;
                            height: 100%;
                        }
                    </style>
                </head>
                <body>
                    <div class="video-wrapper">
                        <div id="player"></div>
                    </div>
                    <script>
                        const lockedVideoId = '$youtubeId';
                        let player;

                        function onYouTubeIframeAPIReady() {
                            player = new YT.Player('player', {
                                videoId: lockedVideoId,
                                playerVars: {
                                    autoplay: 0,
                                    controls: 1,
                                    playsinline: 1,
                                    rel: 0,
                                    fs: 0,
                                    iv_load_policy: 3,
                                    disablekb: 1
                                },
                                events: {
                                    onReady: function() {
                                        window.setInterval(function() {
                                            const currentVideoId = player.getVideoData().video_id;
                                            if (currentVideoId && currentVideoId !== lockedVideoId) {
                                                player.loadVideoById(lockedVideoId);
                                            }
                                        }, 250);
                                    },
                                    onStateChange: function(event) {
                                        const currentVideoId = player.getVideoData().video_id;
                                        if (currentVideoId && currentVideoId !== lockedVideoId) {
                                            player.loadVideoById(lockedVideoId);
                                        } else if (event.data === YT.PlayerState.ENDED) {
                                            player.cueVideoById(lockedVideoId);
                                        }
                                    }
                                }
                            });
                        }
                    </script>
                    <script src="https://www.youtube.com/iframe_api"></script>
                </body>
                </html>
            """.trimIndent()
            webView.loadDataWithBaseURL("https://www.youtube.com", html, "text/html", "UTF-8", null)
        } else if (isPdf && !videoUrl.isNullOrBlank()) {
            val encoded = Uri.encode(videoUrl)
            webView.loadUrl("https://docs.google.com/viewer?embedded=true&url=$encoded")
        } else if (!videoUrl.isNullOrBlank()) {
            val html = """
                <!DOCTYPE html>
                <html>
                <head>
                    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                    <style>
                        * { margin: 0; padding: 0; box-sizing: border-box; }
                        html, body {
                            width: 100%;
                            height: 100%;
                            background-color: #000000;
                            overflow: hidden;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                        }
                        video {
                            width: 100%;
                            height: 100%;
                            object-fit: contain;
                        }
                    </style>
                </head>
                <body>
                    <video src="$videoUrl" controls playsinline controlsList="nodownload"></video>
                </body>
                </html>
            """.trimIndent()
            webView.loadDataWithBaseURL(null, html, "text/html", "UTF-8", null)
        }
    }

    override fun getView(): View = webView

    override fun dispose() {
        webView.apply {
            stopLoading()
            loadUrl("about:blank")
            destroy()
        }
    }
}

