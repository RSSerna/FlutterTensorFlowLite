import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Register the battery level method channel
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.example.native_communicator",binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler{(call: FlutterMethodCall, result: @escaping FlutterResult ) in
      if call.method == "getBatteryLevel" {
        self.getBatteryLevel(result: result)
      } 
      if call.method == "takePicture" {
        self.takePicture(result: result)
      }
      else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  //Get Battery Level
  private func getBatteryLevel(result: @escaping FlutterResult) {
    UIDevice.current.isBatteryMonitoringEnabled = true
    let batteryLevel = UIDevice.current.batteryLevel

    if( batteryLevel < 0 ) {
      result(FlutterError(code: "UNAVAILABLE",
                          message: "Battery level not available.",
                          details: nil))
    } else {
      result("\(Int(batteryLevel * 100))%")
    }
  }

  //Take Picture
  private func takePicture(result: @escaping FlutterResult) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = .camera
    imagePickerController.delegate = self
    imagePickerController.allowsEditing = false
    if let controller = window?.rootViewController {
      controller.present(imagePickerController, animated: true) //, completion: nil)
      // result("Camera opened")
    } else {
      result(FlutterError(code: "UNAVAILABLE",
                          message: "Camera not available.",
                          details: nil))
    }
  }
}

extension AppDelegate: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let image = info[UIImagePickerController.InfoKey.imageUrl] as? URL {
      let imagePath = imageUrl.path

      if let controller = window?.rootViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(name: "com.example.native_communicator", binaryMessenger: controller.binaryMessenger)
        channel.invokeMethod("takePicture", arguments: imagePath)
      }
    }
    picker.dismiss(animated: true, completion: nil)
  } 

  // func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
  //   picker.dismiss(animated: true, completion: nil)
  // }
}