//
//  DeleteValueHandler.swift
//  cloud_kit
//
//  Created by Manuel on 07.04.23.
//

import CloudKit

class DeleteValueHandler: CommandHandler {
    
    var COMMAND_NAME: String = "DELETE_VALUE"
    
    func evaluateExecution(command: String) -> Bool {
        return command == COMMAND_NAME
    }
    
    func handle(command: String, arguments: Dictionary<String, Any>, result: @escaping FlutterResult) {
        if (!evaluateExecution(command: command)) {
            return
        }
        
        if let key = arguments["key"] as? String, let containerId = arguments["containerId"] as? String {
            let database = CKContainer(identifier: containerId).privateCloudDatabase
            let query = CKQuery(recordType: "StorageItem", predicate: NSPredicate(value: true))
            var deletedRecord = false

            database.perform(query, inZoneWith: nil) { (records, error) in
                let deleteGroup = DispatchGroup()

                records?.forEach({ (record) in
                    if record.value(forKey: key) != nil {
                        deleteGroup.enter()
                        database.delete(withRecordID: record.recordID) { (recordId, error) in
                            if recordId != nil, error == nil {
                                deletedRecord = true
                            }
                            deleteGroup.leave()
                        }
                    }
                })

                deleteGroup.notify(queue: .main) {
                    if deletedRecord {
                        result(true)
                    } else {
                        result(false)
                    }
                }
            }
        } else {
            result(FlutterError.init(code: "Error", message: "Cannot pass key parameter", details: nil))
        }
    }
    
    
}
