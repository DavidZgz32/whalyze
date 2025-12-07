package com.example.wra5

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader

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
                    val uriString = call.argument<String>("uri")
                    if (uriString != null) {
                        try {
                            val uri = Uri.parse(uriString)
                            contentResolver.openInputStream(uri)?.use { inputStream ->
                                val reader = BufferedReader(InputStreamReader(inputStream))
                                val content = reader.readText()
                                result.success(content)
                            } ?: result.error("READ_ERROR", "No se pudo abrir el stream", null)
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
        // También verificar el intent en onResume por si la app ya estaba corriendo
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

    private fun getRealPathFromURI(uri: Uri): String? {
        return when (uri.scheme) {
            "file" -> uri.path
            "content" -> {
                // Para content:// URIs, devolver el URI completo
                // Flutter puede leerlo usando contentResolver
                uri.toString()
            }
            else -> uri.toString()
        }
    }
}
