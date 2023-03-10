import CloudKit
import Flutter
import UIKit

public class SwiftCloudKitPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "cloud_kit", binaryMessenger: registrar.messenger())
    let instance = SwiftCloudKitPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "check":
      CKContainer.default().accountStatus { (accountStatus, error) in
        if error != nil {
          result(
            CloudKitResponse(success: false, error: error.debugDescription, data: nil)
              .toDictionary())
        }
        switch accountStatus {
        case .available:
          result(CloudKitResponse(success: true, error: nil, data: nil).toDictionary())
        case .noAccount:
          result(
            CloudKitResponse(success: false, error: "No iCloud account", data: nil).toDictionary())
        case .restricted:
          result(
            CloudKitResponse(success: false, error: "iCloud restricted", data: nil).toDictionary())
        case .temporarilyUnavailable:
          result(
            CloudKitResponse(success: false, error: "iCloud temporarily unavailable", data: nil)
              .toDictionary())
        case .couldNotDetermine:
          result(
            CloudKitResponse(success: false, error: "Unable to determine iCloud status", data: nil)
              .toDictionary())
        @unknown default:
          result(
            CloudKitResponse(
              success: false, error: "default case from switch unknown error", data: nil
            ).toDictionary())
        }
      }
    case "saveRecord":

      if let arguments = call.arguments as? [String: Any],
        let data = arguments["data"] as? [String: String],
        let containerId = arguments["containerId"] as? String,
        let recordType = arguments["recordType"] as? String
      {
        let database = CKContainer(identifier: containerId).privateCloudDatabase
        let query = CKQuery(
          recordType: recordType,
          predicate: NSPredicate(format: "key == \"\(data["key"] ?? "default")\""))

        database.perform(query, inZoneWith: nil) { (records, error) in
          if error != nil {
            result(
              CloudKitResponse(
                success: false, error: "Error while querying existing records", data: nil
              ).toDictionary())
          }
          let record: CKRecord
          if records?.count != 0 && records?.first != nil {
            record = (records?.first)!
            record.setValuesForKeys(data)
          } else {
            record = CKRecord(recordType: recordType)
            record.setValuesForKeys(data)
          }
          database.save(record) { record, error in
            if record != nil, error == nil {
              result(CloudKitResponse(success: true, error: nil, data: nil).toDictionary())
            } else {
              result(
                CloudKitResponse(
                  success: false, error: "Error while saving record see details", data: nil
                ).toDictionary())
            }
          }
        }
      } else {
        result(
          CloudKitResponse(success: false, error: "Cannot pass parameters", data: nil)
            .toDictionary())
      }

    case "getRecords":

      if let arguments = call.arguments as? [String: Any],
        let containerId = arguments["containerId"] as? String,
        let recordType = arguments["recordType"] as? String
      {
        let database = CKContainer(identifier: containerId).privateCloudDatabase
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))

        database.perform(query, inZoneWith: nil) { (records, error) in
          if error != nil {
            result(
              CloudKitResponse(
                success: false, error: "Error while querying existing records", data: nil
              ).toDictionary())
          }
          let queryResult: [[String: String]] =
            records?.compactMap { record in
              if let key = record.value(forKey: "key") as? String,
                let data = record.value(forKey: "data") as? String,
                let name = record.value(forKey: "name") as? String,
                let version = record.value(forKey: "version") as? String
              {
                return ["key": key, "data": data, "name": name, "version": version]
              } else {
                return nil
              }
            } ?? []
          result(
            CloudKitResponse(success: true, error: nil, data: queryResult).toDictionary())
        }
      } else {
        result(
          CloudKitResponse(success: false, error: "Cannot pass parameters", data: nil)
            .toDictionary())
      }

    case "deleteRecord":

      if let arguments = call.arguments as? [String: Any],
        let key = arguments["key"] as? String,
        let containerId = arguments["containerId"] as? String,
        let recordType = arguments["recordType"] as? String
      {

        let database = CKContainer(identifier: containerId).privateCloudDatabase

        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))

        database.perform(query, inZoneWith: nil) { (records, error) in
          if (error) != nil {
            result(
              CloudKitResponse(success: false, error: "DB delete error see details", data: nil)
                .toDictionary())
          }
          records?.forEach({ (record) in

            if record.value(forKey: "key") as! String == key {
              database.delete(withRecordID: record.recordID) { (recordId, error) in
                if (error) != nil {
                  result(
                    CloudKitResponse(
                      success: false, error: "DB delete error see details", data: nil
                    )
                    .toDictionary())

                }
              }

            }

          })
        }
      } else {
        result(
          CloudKitResponse(success: false, error: "Cannot pass key and value parameter", data: nil)
            .toDictionary())
      }

    case "deleteAll":

      if let arguments = call.arguments as? [String: Any],
        let containerId = arguments["containerId"] as? String,
        let recordType = arguments["recordType"] as? String
      {

        let database = CKContainer(identifier: containerId).privateCloudDatabase

        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))

        database.perform(query, inZoneWith: nil) { (records, error) in
          if (error) != nil {

            result(
              CloudKitResponse(success: false, error: "DB delete all error see details", data: nil)
                .toDictionary())

          }
          records?.forEach({ (record) in

            database.delete(withRecordID: record.recordID) { (recordId, error) in
              if (error) != nil {

                result(
                  CloudKitResponse(
                    success: false, error: "DB delete all error see details", data: nil
                  )
                  .toDictionary())

              }
            }

          })

        }

      } else {
        result(
          CloudKitResponse(success: false, error: "Cannot pass key and value parameter", data: nil)
            .toDictionary())
      }

    case "save":

      if let arguments = call.arguments as? [String: Any],
        let key = arguments["key"] as? String,
        let value = arguments["value"] as? String,
        let containerId = arguments["containerId"] as? String,
        let recordType = arguments["recordType"] as? String
      {

        let database = CKContainer(identifier: containerId).privateCloudDatabase

        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))

        database.perform(query, inZoneWith: nil) { (records, error) in

          let foundRecords = records?.compactMap({ $0.value(forKey: key) as? String })

          if foundRecords?.count != 0 {
                result(
          CloudKitResponse(success: false, error: "This key already exists in the database", data: nil)
            .toDictionary())
          }

        }

        let record = CKRecord(recordType: recordType)
        record.setValue(value, forKey: key)

        database.save(record) { (record, error) in
          if record != nil, error == nil {
            result(CloudKitResponse(success: true, error: nil, data: nil).toDictionary())
          } else {
            result(CloudKitResponse(success: false, error: "Cannot save record", data: nil).toDictionary())
          }
        }
      } else {
        result(CloudKitResponse(success: false, error: "Cannot pass parameters", data: nil).toDictionary())
      }

    case "getKeys":
      if let arguments = call.arguments as? [String: Any],
        let containerId = arguments["containerId"] as? String
      {

        let database = CKContainer(identifier: containerId).privateCloudDatabase

        let query = CKQuery(recordType: "StorageItem", predicate: NSPredicate(value: true))

        database.perform(query, inZoneWith: nil) { (records, error) in

          var keys: [String] = []
          for record in records ?? [] {
            keys.append(contentsOf: record.allKeys())
          }
          result(CloudKitResponse(success: true, error: nil, data: keys).toDictionary())

        }

      } else {
        result(CloudKitResponse(success: false, error: "Cannot pass parameters", data: nil).toDictionary())
      }

    case "get":

      if let arguments = call.arguments as? [String: Any],
        let key = arguments["key"] as? String,
        let containerId = arguments["containerId"] as? String
      {

        let database = CKContainer(identifier: containerId).privateCloudDatabase

        let query = CKQuery(recordType: "StorageItem", predicate: NSPredicate(value: true))

        database.perform(query, inZoneWith: nil) { (records, error) in

          let foundRecords = records?.compactMap({ $0.value(forKey: key) as? String })

          result(CloudKitResponse(success: true, error: nil, data: foundRecords).toDictionary())

        }

      } else {
        result(CloudKitResponse(success: false, error: "Cannot pass parameters", data: nil).toDictionary())
      }

    case "delete":

      if let arguments = call.arguments as? [String: Any],
        let key = arguments["key"] as? String,
        let containerId = arguments["containerId"] as? String
      {

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
       result(CloudKitResponse(success: false, error: "Cannot pass parameters", data: nil).toDictionary())
      }

    default:
     result(CloudKitResponse(success: false, error: "Not Implemented", data: nil).toDictionary())
    }

  }

}

struct CloudKitResponse {
  let success: Bool
  let error: String?
  let data: Any?

  func toDictionary() -> [String: Any] {
    let reflect = Mirror(reflecting: self)
    let children = reflect.children
    let dictionary = toAnyHashable(elements: children)
    return dictionary
  }

  func toAnyHashable(elements: AnyCollection<Mirror.Child>) -> [String: Any] {
    var dictionary: [String: Any] = [:]
    for element in elements {
      if let key = element.label {

        if let collectionValidHashable = element.value as? [AnyHashable] {
          dictionary[key] = collectionValidHashable
        }

        if let validHashable = element.value as? AnyHashable {
          dictionary[key] = validHashable
        }

        if let convertor = element.value as? CloudKitResponse {
          dictionary[key] = convertor.toDictionary()
        }

        if let convertorList = element.value as? [CloudKitResponse] {
          dictionary[key] = convertorList.map({ e in
            e.toDictionary()
          })
        }
      }
    }
    return dictionary
  }
}
