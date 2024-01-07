//
//  SaveRecordHandler.swift
//  cloud_kit
//
//  Created by Manuel on 03.01.24.
//

import CloudKit

class SaveRecordHandler: CommandHandler {
    
    var COMMAND_NAME: String = "SAVE_RECORD"
    
    func evaluateExecution(command: String) -> Bool {
        return command == COMMAND_NAME
    }
    
    func handle(command: String, arguments: Dictionary<String, Any>, result: @escaping FlutterResult) {
        if (!evaluateExecution(command: command)) {
            return
        }
        
        if let containerId: String = arguments["containerId"] as? String, let values: Dictionary<String, Any> = arguments["values"] as? [String: Any], let recordName: String = arguments["recordName"] as? String {
            let database: CKDatabase = CKContainer(identifier: containerId).privateCloudDatabase
            let record: CKRecord = CKRecord(recordType: recordName)
            
            values.forEach { (key: String, value: Any) in
                record.setValue(value, forKey: key)
            }

            database.save(record) { (record: CKRecord?, error: Error?) in
                if record != nil, error == nil {
                    result(true)
                } else {
                    result(false)
                }
            }
            
         } else {
            result(FlutterError.init(code: "Error", message: "There is a problem with the parameters", details: nil))
         }
    }
    
    
}
