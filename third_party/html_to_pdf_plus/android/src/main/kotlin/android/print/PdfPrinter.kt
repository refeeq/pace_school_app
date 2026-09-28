package android.print

import android.os.Build
import android.os.CancellationSignal
import android.os.ParcelFileDescriptor
import java.io.File
import java.util.concurrent.atomic.AtomicBoolean

class PdfPrinter(private val printAttributes: PrintAttributes) {

    interface Callback {
        fun onSuccess(filePath: String)
        fun onFailure()
    }

    fun print(
        printAdapter: PrintDocumentAdapter,
        path: File,
        fileName: String,
        callback: Callback
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            callback.onFailure()
            return
        }

        val replied = AtomicBoolean(false)
        fun succeed(filePath: String) {
            if (replied.compareAndSet(false, true)) {
                callback.onSuccess(filePath)
            }
        }
        fun fail() {
            if (replied.compareAndSet(false, true)) {
                callback.onFailure()
            }
        }

        try {
            printAdapter.onLayout(
                null,
                printAttributes,
                null,
                object : PrintDocumentAdapter.LayoutResultCallback() {
                    override fun onLayoutFinished(info: PrintDocumentInfo, changed: Boolean) {
                        try {
                            printAdapter.onWrite(
                                arrayOf(PageRange.ALL_PAGES),
                                getOutputFile(path, fileName),
                                CancellationSignal(),
                                object : PrintDocumentAdapter.WriteResultCallback() {
                                    override fun onWriteFinished(pages: Array<PageRange>) {
                                        if (pages.isEmpty()) {
                                            fail()
                                            return
                                        }
                                        succeed(File(path, fileName).absolutePath)
                                    }

                                    override fun onWriteFailed(error: CharSequence?) {
                                        fail()
                                    }

                                    override fun onWriteCancelled() {
                                        fail()
                                    }
                                }
                            )
                        } catch (_: Throwable) {
                            fail()
                        }
                    }

                    override fun onLayoutFailed(error: CharSequence?) {
                        fail()
                    }

                    override fun onLayoutCancelled() {
                        fail()
                    }
                },
                null
            )
        } catch (_: Throwable) {
            fail()
        }
    }
}

private fun getOutputFile(path: File, fileName: String): ParcelFileDescriptor {
    if (!path.exists()) {
        path.mkdirs()
    }

    val file = File(path, fileName)
    if (!file.exists()) {
        file.createNewFile()
    }
    return ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_WRITE)
}
