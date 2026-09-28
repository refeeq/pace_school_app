package com.khizar1556.html_to_pdf_plus

import android.annotation.SuppressLint
import android.app.Activity
import android.os.Build
import android.print.PdfPrinter
import android.print.PrintAttributes
import android.graphics.pdf.PdfDocument
import android.view.View
import android.webkit.WebView
import android.webkit.WebViewClient
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.atomic.AtomicBoolean

class HtmlToPdfConverter {

    interface Callback {
        fun onSuccess(filePath: String)
        fun onFailure()
    }

    @SuppressLint("SetJavaScriptEnabled")
    fun convert(
        filePath: String,
        activity: Activity,
        printSize: String,
        orientation: String,
        fitToSinglePage: Boolean,
        callback: Callback
    ) {
        activity.runOnUiThread {
            val started = AtomicBoolean(false)
            try {
                val htmlContent = File(filePath).readText(Charsets.UTF_8)
                val webView = WebView(activity)
                webView.settings.javaScriptEnabled = true
                webView.settings.javaScriptCanOpenWindowsAutomatically = true
                webView.settings.allowFileAccess = true
                webView.webViewClient = object : WebViewClient() {
                    override fun onPageFinished(view: WebView, url: String) {
                        super.onPageFinished(view, url)
                        if (!started.compareAndSet(false, true)) return
                        createPdfFromWebView(
                            webView,
                            activity,
                            printSize,
                            orientation,
                            fitToSinglePage,
                            callback
                        )
                    }
                }
                webView.loadDataWithBaseURL(null, htmlContent, "text/HTML", "UTF-8", null)
                webView.postDelayed({
                    if (started.compareAndSet(false, true)) {
                        destroyQuietly(activity, webView)
                        callback.onFailure()
                    }
                }, 20000)
            } catch (_: Throwable) {
                if (started.compareAndSet(false, true)) {
                    callback.onFailure()
                }
            }
        }
    }

    fun createPdfFromWebView(
        webView: WebView,
        activity: Activity,
        printSize: String,
        orientation: String,
        fitToSinglePage: Boolean,
        callback: Callback
    ) {
        try {
            val path = activity.filesDir
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
                destroyQuietly(activity, webView)
                callback.onFailure()
                return
            }

            var mediaSize = PrintAttributes.MediaSize.ISO_A4
            when (printSize) {
                "A0" -> mediaSize = PrintAttributes.MediaSize.ISO_A0
                "A1" -> mediaSize = PrintAttributes.MediaSize.ISO_A1
                "A2" -> mediaSize = PrintAttributes.MediaSize.ISO_A2
                "A3" -> mediaSize = PrintAttributes.MediaSize.ISO_A3
                "A4" -> mediaSize = PrintAttributes.MediaSize.ISO_A4
                "A5" -> mediaSize = PrintAttributes.MediaSize.ISO_A5
                "A6" -> mediaSize = PrintAttributes.MediaSize.ISO_A6
                "A7" -> mediaSize = PrintAttributes.MediaSize.ISO_A7
                "A8" -> mediaSize = PrintAttributes.MediaSize.ISO_A8
                "A9" -> mediaSize = PrintAttributes.MediaSize.ISO_A9
                "A10" -> mediaSize = PrintAttributes.MediaSize.ISO_A10
            }

            when (orientation) {
                "LANDSCAPE" -> mediaSize = mediaSize.asLandscape()
                "PORTRAIT" -> mediaSize = mediaSize.asPortrait()
            }

            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
                destroyQuietly(activity, webView)
                callback.onFailure()
                return
            }

            if (fitToSinglePage) {
                drawReceiptAsOnePage(webView, activity, path, mediaSize, callback)
            } else {
                printWebView(webView, activity, path, mediaSize, callback)
            }
        } catch (_: Throwable) {
            destroyQuietly(activity, webView)
            callback.onFailure()
        }
    }

    private fun drawReceiptAsOnePage(
        webView: WebView,
        activity: Activity,
        path: File,
        mediaSize: PrintAttributes.MediaSize,
        callback: Callback
    ) {
        val density = activity.resources.displayMetrics.density
        val widthCss = mediaSize.widthMils / 1000f * 96f
        val widthPx = (widthCss * density).toInt().coerceAtLeast(1)
        webView.setLayerType(View.LAYER_TYPE_SOFTWARE, null)
        webView.measure(
            View.MeasureSpec.makeMeasureSpec(widthPx, View.MeasureSpec.EXACTLY),
            View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
        )
        webView.layout(0, 0, widthPx, webView.measuredHeight.coerceAtLeast(1))

        val queued = webView.post {
            webView.evaluateJavascript(
                "(function(){return Math.max(document.body?document.body.scrollHeight:0, document.documentElement?document.documentElement.scrollHeight:0);})()"
            ) { raw ->
                val fromJs = raw?.trim()?.removeSurrounding("\"")?.toFloatOrNull() ?: 0f
                val contentCss = if (fromJs > 0f) fromJs else webView.contentHeight.toFloat()
                activity.runOnUiThread {
                    val heightPx = ((if (contentCss > 0f) contentCss else webView.contentHeight.toFloat()) * density)
                        .toInt()
                        .coerceAtLeast(1)
                    try {
                        webView.measure(
                            View.MeasureSpec.makeMeasureSpec(widthPx, View.MeasureSpec.EXACTLY),
                            View.MeasureSpec.makeMeasureSpec(heightPx, View.MeasureSpec.EXACTLY)
                        )
                        webView.layout(0, 0, widthPx, heightPx)
                        val document = PdfDocument()
                        val pageInfo = PdfDocument.PageInfo.Builder(widthPx, heightPx, 1).create()
                        val page = document.startPage(pageInfo)
                        webView.draw(page.canvas)
                        document.finishPage(page)
                        val file = File(path, temporaryFileName)
                        FileOutputStream(file).use { document.writeTo(it) }
                        document.close()
                        destroyQuietly(activity, webView)
                        callback.onSuccess(file.absolutePath)
                    } catch (_: Throwable) {
                        destroyQuietly(activity, webView)
                        callback.onFailure()
                    }
                }
            }
        }
        if (!queued) {
            destroyQuietly(activity, webView)
            callback.onFailure()
        }
    }

    private fun printWebView(
        webView: WebView,
        activity: Activity,
        path: java.io.File,
        mediaSize: PrintAttributes.MediaSize,
        callback: Callback
    ) {
        try {
            val attributes = PrintAttributes.Builder()
                .setMediaSize(mediaSize)
                .setResolution(PrintAttributes.Resolution("pdf", "pdf", 300, 300))
                .setMinMargins(PrintAttributes.Margins.NO_MARGINS)
                .build()

            val printer = PdfPrinter(attributes)
            val adapter = webView.createPrintDocumentAdapter(temporaryDocumentName)
            printer.print(adapter, path, temporaryFileName, object : PdfPrinter.Callback {
                override fun onSuccess(filePath: String) {
                    destroyQuietly(activity, webView)
                    callback.onSuccess(filePath)
                }

                override fun onFailure() {
                    destroyQuietly(activity, webView)
                    callback.onFailure()
                }
            })
        } catch (_: Throwable) {
            destroyQuietly(activity, webView)
            callback.onFailure()
        }
    }

    private fun destroyQuietly(activity: Activity, webView: WebView) {
        activity.runOnUiThread {
            try {
                webView.stopLoading()
                webView.destroy()
            } catch (_: Throwable) {
            }
        }
    }

    companion object {
        const val temporaryDocumentName = "TemporaryDocumentName"
        const val temporaryFileName = "TemporaryDocumentFile.pdf"
    }
}
