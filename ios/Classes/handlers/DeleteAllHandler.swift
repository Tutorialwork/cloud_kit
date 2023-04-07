//
//  DeleteAllHandler.swift
//  cloud_kit
//
//  Created by Manuel on 07.04.23.
//

import CloudKit

class DeleteAllHandler: CommandHandler {
    
    var COMMAND_NAME: String = "DELETE_ALL"
    
    func evaluateExecution(command: String) -> Bool {
        return command == COMMAND_NAME
    }
    
    func handle(command: String, arguments: Dictionary<String, Any>, result: @escaping FlutterResult) {
        if (!evaluateExecution(command: command)) {
            return
        }
        
        if let containerId = arguments["containerId"] as? String {
            let database = CKContainer(identifier: containerId).privateCloudDatabase

            let query = CKQuery(recordType: "StorageItem", predicate: NSPredicate(value: true))
            let deleteGroup = DispatchGroup()

            database.perform(query, inZoneWith: nil) { (records, error) in

                records?.forEach({ (record) in
                    deleteGroup.enter()
                    database.delete(withRecordID: record.recordID) { (recordId, error) in
                        deleteGroup.leave()
                    }
                })

                deleteGroup.notify(queue: .main) {
                    result(true)
                }
            }
         } else {
            result(FlutterError.init(code: "Error", message: "Cannot pass containerId parameter", details: nil))
         }
    }
    
    
}
