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
    switch call.method {
    case "check":
        if FileManager.default.ubiquityIdentityToken != nil {
            print("iCloud Available")
            result(true)
        } else {
            print("iCloud Unavailable")
            result(false)
        }
        
    case "save":
        
        if let arguments = call.arguments as? Dictionary<String, Any>,
           let key = arguments["key"] as? String,
           let value = arguments["value"] as? String,
           let containerId = arguments["containerId"] as? String,
           let recordType = arguments["recordType"] as? String {
            
            let database = CKContainer(identifier: containerId).privateCloudDatabase

            let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
            
            database.perform(query, inZoneWith: nil) { (records, error) in

                let foundRecords = records?.compactMap({ $0.value(forKey: key) as? String })
                
                if foundRecords?.count != 0 {
                    result(FlutterError.init(code: "Error", message: "This key already exists in the database", details: nil))
                }
        
            }
                        
            let record = CKRecord(recordType: recordType)
            record.setValue(value, forKey: key)
            
            database.save(record) { (record, error) in
                if record != nil, error == nil {
                    result(true)
                } else {
                    result(false)
                }
            }
         } else {
            result(FlutterError.init(code: "Error", message: "Cannot pass key and value parameter", details: nil))
         }
    
    case "saveRecord":
        
        if let arguments = call.arguments as? Dictionary<String, Any>,
           let data = arguments["data"] as? Dictionary<String,String>,
           let containerId = arguments["containerId"] as? String,
           let recordType = arguments["recordType"] as? String {
            let database = CKContainer(identifier: containerId).privateCloudDatabase
            let record = CKRecord(recordType: recordType)
            
            record.setValuesForKeys(data)
            
            database.save(record) { record, error in
                if record != nil, error == nil {
                    result(true)
                } else {
                    result(false)
                }
            }
        }else {
            result(FlutterError.init(code: "Error", message: "Cannot pass parameters", details: nil))
         }
        
    case "getRecords":
        
        if let arguments = call.arguments as? Dictionary<String, Any>,
           let containerId = arguments["containerId"] as? String,
           let recordType = arguments["recordType"] as? String {
            let database = CKContainer(identifier: containerId).privateCloudDatabase
            let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
            
            database.perform(query, inZoneWith: nil){ (records, error) in
                let queryResult: [Dictionary<String, String>] = records?.compactMap { record in
                    if let key = record.value(forKey: "key") as? String, let data = record.value(forKey: "data") as? String {
                      return ["key": key, "data": data]
                    }else {
                        return nil
                    }
                } ?? []
                
                    result(queryResult)
                
                if((error) != nil){
                    
                    result(FlutterError.init(code: "Error", message: "DB Data Error", details: error))
                    
                }
            }
            
        }else {
            result(FlutterError.init(code: "Error", message: "Cannot pass parameters", details: nil))
         }
        
        
    case "getKeys":
        if let arguments = call.arguments as? Dictionary<String, Any>,
           let containerId = arguments["containerId"] as? String {
            
            let database = CKContainer(identifier: containerId).privateCloudDatabase

           
            let query = CKQuery(recordType: "StorageItem", predicate: NSPredicate(value: true))
            
            database.perform(query, inZoneWith: nil) { (records, error) in

                var keys:[String] = []
                for record in records ?? [] {
                    keys.append(contentsOf: record.allKeys())
                }
                result(keys)

            }
            
         } else {
            result(FlutterError.init(code: "Error", message: "Cannot pass key and value parameter", details: nil))
         }

    case "get":
        
        if let arguments = call.arguments as? Dictionary<String, Any>,
           let key = arguments["key"] as? String,
           let containerId = arguments["containerId"] as? String {
            
            let database = CKContainer(identifier: containerId).privateCloudDatabase

           
            let query = CKQuery(recordType: "StorageItem", predicate: NSPredicate(value: true))
            
            database.perform(query, inZoneWith: nil) { (records, error) in

                let foundRecords = records?.compactMap({ $0.value(forKey: key) as? String })
                
                result(foundRecords)
        
            }
            
         } else {
            result(FlutterError.init(code: "Error", message: "Cannot pass key and value parameter", details: nil))
         }
        
    case "deleteRecord":
        
        if let arguments = call.arguments as? Dictionary<String, Any>,
           let key = arguments["key"] as? String,
           let containerId = arguments["containerId"] as? String,
           let recordType = arguments["recordType"] as? String {
            
            let database = CKContainer(identifier: containerId).privateCloudDatabase

           
            let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
            
            database.perform(query, inZoneWith: nil) { (records, error) in
                
                records?.forEach({ (record) in
                    
                    if record.value(forKey: "key") as! String == key {
                        database.delete(withRecordID: record.recordID) { (recordId, error) in
                            
                        }
                        
                    }
                    
                    
                })
                
                
            }
            
         } else {
            result(FlutterError.init(code: "Error", message: "Cannot pass key and value parameter", details: nil))
         }
        
    case "delete":
        
        if let arguments = call.arguments as? Dictionary<String, Any>,
           let key = arguments["key"] as? String,
           let containerId = arguments["containerId"] as? String {
            
            let database = CKContainer(identifier: containerId).privateCloudDatabase

           
            let query = CKQuery(recordType: "StorageItem", predicate: NSPredicate(value: true))
            
            database.perform(query, inZoneWith: nil) { (records, error) in
                
                records?.forEach({ (record) in
                    
                    if record.value(forKey: key) != nil {
                        database.delete(withRecordID: record.recordID) { (recordId, error) in
                            
                        }
                        
                    }
                    
                    
                })
                
                
            }
            
         } else {
            result(FlutterError.init(code: "Error", message: "Cannot pass key and value parameter", details: nil))
         }
        
    case "deleteAll":
        
        if let arguments = call.arguments as? Dictionary<String, Any>,
           let containerId = arguments["containerId"] as? String,
           let recordType = arguments["recordType"] as? String {
            
            let database = CKContainer(identifier: containerId).privateCloudDatabase
           
            let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
            
            database.perform(query, inZoneWith: nil) { (records, error) in
                
                records?.forEach({ (record) in
                
                    database.delete(withRecordID: record.recordID) { (recordId, error) in
                        
                    }

                    
                })
                
                
            }
            
         } else {
            result(FlutterError.init(code: "Error", message: "Cannot pass key and value parameter", details: nil))
         }
        
    default:
        result(FlutterError.init(code: "Error", message: "Not implemented", details: nil))
    }
    
  }
    
}
