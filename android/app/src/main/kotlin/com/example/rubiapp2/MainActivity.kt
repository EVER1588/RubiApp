package com.example.rubiapp2

import android.media.audiofx.Equalizer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var equalizer: Equalizer? = null
    private val CHANNEL = "com.example.rubiapp2/equalizer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableBassReduction" -> {
                        applyBassReduction(true)
                        result.success(null)
                    }
                    "disableBassReduction" -> {
                        applyBassReduction(false)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun applyBassReduction(enable: Boolean) {
        try {
            equalizer?.release()
            equalizer = null
            if (enable) {
                equalizer = Equalizer(0, 0).apply {
                    enabled = true
                    val minLevel = bandLevelRange[0].toInt()
                    for (i in 0 until numberOfBands) {
                        // getCenterFreq devuelve milliHz; 200 Hz = 200 000 milliHz
                        if (getCenterFreq(i.toShort()) <= 200_000) {
                            val reduced = (getBandLevel(i.toShort()).toInt() - 1000)
                                .coerceAtLeast(minLevel)
                            setBandLevel(i.toShort(), reduced.toShort())
                        }
                    }
                }
            }
        } catch (_: Exception) {
            // El dispositivo no soporta Equalizer, ignorar
        }
    }

    override fun onDestroy() {
        equalizer?.release()
        equalizer = null
        super.onDestroy()
    }
}
