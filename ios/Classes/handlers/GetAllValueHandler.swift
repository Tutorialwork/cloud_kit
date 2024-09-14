//
//  GetValueHandler.swift
//  cloud_kit
//
//  Created by Manuel on 14.09.24.
//

import CloudKit

class GetAllValueHandler: CommandHandler {
    
    var COMMAND_NAME: String = "GET_ALL_VALUE"
    
    func evaluateExecution(command: String) -> Bool {
        return command == COMMAND_NAME
    }
    
    func handle(command: String, arguments: Dictionary<String, Any>, result: @escaping FlutterResult) {
        if (!evaluateExecution(command: command)) {
            return
        }
        
        if let containerId = arguments["containerId"] as? String {
            let database: CKDatabase = CKContainer(identifier: containerId).privateCloudDatabase

            let query: CKQuery = CKQuery(recordType: "StorageItem", predicate: NSPredicate(value: true))
            var results: [String: String] = [:]

            database.perform(query, inZoneWith: nil) { (records, error) in
                records?.forEach({ record in
                    let element: Dictionary<String, String>.Element? = self.getRecordKeyAndValue(record: record)
                    if let (key, value) = element {
                        results[key] = value
                    }
                })
                result(results)
            }
         } else {
            result(FlutterError.init(code: "Error", message: "Cannot pass key and value parameter", details: nil))
         }
    }
    
    func getRecordKeyAndValue(record: CKRecord) -> Dictionary<String, String>.Element? {
        for key in record.allKeys() {
            if let value: String = record.value(forKey: key) as? String {
                return (key, value)
            }
        }
        
        return nil
    }
    
    
}
