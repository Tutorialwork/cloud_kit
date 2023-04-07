//
//  GetValueHandler.swift
//  cloud_kit
//
//  Created by Manuel on 07.04.23.
//

import CloudKit

class GetValueHandler: CommandHandler {
    
    var COMMAND_NAME: String = "GET_VALUE"
    
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

            database.perform(query, inZoneWith: nil) { (records, error) in
                let foundRecords = records?.compactMap({ $0.value(forKey: key) as? String })

                result(foundRecords)
            }
         } else {
            result(FlutterError.init(code: "Error", message: "Cannot pass key and value parameter", details: nil))
         }
    }
    
    
}
