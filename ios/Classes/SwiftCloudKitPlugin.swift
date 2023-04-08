import Flutter
import UIKit
import CloudKit

public class SwiftCloudKitPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "cloud_kit", binaryMessenger: registrar.messenger())
      let instance = SwiftCloudKitPlugin()
      registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      let callArguments: Dictionary<String, Any> = call.arguments as! Dictionary<String, Any>
      
      GetValueHandler().handle(command: call.method, arguments: callArguments, result: result)
      SaveValueHandler().handle(command: call.method, arguments: callArguments, result: result)
      DeleteValueHandler().handle(command: call.method, arguments: callArguments, result: result)
      DeleteAllHandler().handle(command: call.method, arguments: callArguments, result: result)
      GetAccountStatusHandler().handle(command: call.method, arguments: callArguments, result: result)
  }

}
