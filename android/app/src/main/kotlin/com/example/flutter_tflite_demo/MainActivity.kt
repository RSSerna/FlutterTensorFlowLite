import android.os.bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

package com.example.flutter_tflite_demo


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.native_communicator"

    override fun OnCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine?.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatterryLevel()

                if (batteryLevel != -1) {
                    result.success("Battery Level: $batteryLevel%")
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else if (call.method == "takePicture") {
                takePicture(result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getBatterryLevel(): Int {
        val batteryManager = getSystemService(BATTERY_SERVICE) as android.os.BatteryManager
        return batteryManager.getIntProperty(android.os.BatteryManager.BATTERY_PROPERTY_CAPACITY)  
    }

    private void takePicture() {
        Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        if (takePictureIntent.resolveActivity(getPackageManager()) != null) {
            // startActivityForResult(takePictureIntent, REQUEST_IMAGE_CAPTURE);
            startActivityResult(takePictureIntent, 1);
        } else
        {
            result.error("UNAVAILABLE", "Camera not available.", null)
        }
    }

    @override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 1 && resultCode == Activity.RESULT_OK && data != null) {
            String imagePath = data.getData().toString();
            new MethodChannel(flutterEngine?.dartExecutor, CHANNEL).invokeMethod("takePicture", imagePath);
        }
    }
}
