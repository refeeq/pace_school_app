package com.khizar1556.html_to_pdf_plus

import android.app.Activity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.atomic.AtomicBoolean

/** FlutterHtmlToPdfPlugin */
class FlutterHtmlToPdfPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private val isConverting = AtomicBoolean(false)

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_html_to_pdf")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "convertHtmlToPdf") {
            convertHtmlToPdf(call, result)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    private fun convertHtmlToPdf(call: MethodCall, result: Result) {
        if (!isConverting.compareAndSet(false, true)) {
            result.error("BUSY", "A PDF conversion is already in progress.", null)
            return
        }

        val htmlFilePath = call.argument<String>("htmlFilePath")
        val printSize = call.argument<String>("printSize")
        val orientation = call.argument<String>("orientation")
        if (htmlFilePath.isNullOrEmpty() || printSize.isNullOrEmpty() || orientation.isNullOrEmpty()) {
            isConverting.set(false)
            result.error("INVALID_ARGS", "htmlFilePath, printSize, and orientation are required.", null)
            return
        }

        val fitToSinglePage = call.argument<Boolean>("fitToSinglePage") ?: false
        val host = activity
        if (host == null) {
            isConverting.set(false)
            result.error("NO_ACTIVITY", "Unable to convert html to pdf document!", null)
            return
        }

        val replied = AtomicBoolean(false)
        HtmlToPdfConverter().convert(
            htmlFilePath,
            host,
            printSize,
            orientation,
            fitToSinglePage,
            object : HtmlToPdfConverter.Callback {
                override fun onSuccess(filePath: String) {
                    if (!replied.compareAndSet(false, true)) return
                    isConverting.set(false)
                    result.success(filePath)
                }

                override fun onFailure() {
                    if (!replied.compareAndSet(false, true)) return
                    isConverting.set(false)
                    result.error("ERROR", "Unable to convert html to pdf document!", null)
                }
            }
        )
    }
}
