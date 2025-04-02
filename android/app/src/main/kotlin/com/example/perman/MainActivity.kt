package com.example.perman

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.PackageManager
import android.content.pm.PackageInfo

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.perman/permissions"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getPermissions") {
                try {
                    val packageName = call.arguments as String
                    val packageManager = context.packageManager
                    val packageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS)

                    val permissions = packageInfo.requestedPermissions
                    if (permissions != null) {
                        result.success(permissions.toList())
                    } else {
                        result.success(listOf<String>())
                    }
                } catch (e: Exception) {
                    result.error("PERMISSION_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
