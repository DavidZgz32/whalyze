package com.example.wra5

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.wra5/file"
    private var sharedFilePath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSharedFile" -> {
                    result.success(sharedFilePath)
                    sharedFilePath = null // Limpiar después de usar
                }
                "readContentUri" -> {
                    // Mantenido por compatibilidad; preferir copiar a temp en handleIntent
                    val uriString = call.argument<String>("uri")
                    if (uriString != null) {
                        try {
                            val uri = Uri.parse(uriString)
                            val tempFile = copyContentUriToTempFile(uri)
                            if (tempFile != null) {
                                result.success(tempFile.absolutePath)
                            } else {
                                result.error("READ_ERROR", "No se pudo copiar el archivo", null)
                            }
                        } catch (e: Exception) {
                            result.error("READ_ERROR", "Error al leer el archivo: ${e.message}", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "URI no proporcionado", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent?.action == Intent.ACTION_VIEW || intent?.action == Intent.ACTION_SEND) {
            val uri: Uri? = when {
                intent?.action == Intent.ACTION_SEND -> {
                    intent.getParcelableExtra(Intent.EXTRA_STREAM) as? Uri 
                        ?: intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
                }
                else -> intent?.data
            }
            uri?.let {
                sharedFilePath = getRealPathFromURI(it)
            }
        }
    }

    /**
     * Para content:// URIs (p. ej. al abrir con Whalyze desde WhatsApp), copiamos el archivo
     * a un temporal para que Flutter pueda leerlo como File (y descomprimir ZIP con flutter_archive).
     * En release en dispositivo, leer el URI como texto fallaba con archivos ZIP.
     */
    private fun getRealPathFromURI(uri: Uri): String? {
        return when (uri.scheme) {
            "file" -> uri.path
            "content" -> {
                copyContentUriToTempFile(uri)?.absolutePath ?: uri.toString()
            }
            else -> uri.toString()
        }
    }

    private fun copyContentUriToTempFile(uri: Uri): File? {
        return try {
            contentResolver.openInputStream(uri)?.use { input: InputStream ->
                val ext = contentResolver.getType(uri)?.let { type ->
                    when {
                        type.contains("zip") -> ".zip"
                        type.contains("plain") || type.contains("text") -> ".txt"
                        else -> ""
                    }
                } ?: ".bin"
                val tempFile = File(cacheDir, "shared_${System.currentTimeMillis()}$ext")
                FileOutputStream(tempFile).use { output ->
                    input.copyTo(output)
                }
                tempFile
            }
        } catch (e: Exception) {
            null
        }
    }
}
