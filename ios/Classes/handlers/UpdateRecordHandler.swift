//
//  UpdateRecordHandler.swift
//  cloud_kit
//
//  Created by Manuel on 09.01.24.
//

import CloudKit

class UpdateRecordHandler: CommandHandler {
    
    var COMMAND_NAME: String = "UPDATE_RECORD"
    
    func evaluateExecution(command: String) -> Bool {
        return command == COMMAND_NAME
    }
    
    func handle(command: String, arguments: Dictionary<String, Any>, result: @escaping FlutterResult) {
        if (!evaluateExecution(command: command)) {
            return
        }
        
        if let containerId: String = arguments["containerId"] as? String, let values: Dictionary<String, Any> = arguments["values"] as? [String: Any], let recordId: String = arguments["recordId"] as? String {
            let database: CKDatabase = CKContainer(identifier: containerId).privateCloudDatabase
            let recordIdObject: CKRecord.ID = CKRecord.ID(recordName: recordId)
            let fetchOperation: CKFetchRecordsOperation = CKFetchRecordsOperation(recordIDs: [recordIdObject])
            
            fetchOperation.fetchRecordsCompletionBlock = { (records: Dictionary<CKRecord.ID, CKRecord>?, error: Error?) in
                if error != nil {
                    result(FlutterError.init(code: "Error", message: "The record is not found", details: nil))
                }
                
                if let records: Dictionary<CKRecord.ID, CKRecord> = records {
                    if let record: CKRecord = records[recordIdObject] {
                        values.forEach { (key: String, value: Any) in
                            record.setValue(value, forKey: key)
                        }
                        
                        database.save(record) { (record: CKRecord?, error: Error?) in
                            result(error == nil)
                        }
                    }
                }
            }
            
            
            database.add(fetchOperation)
         } else {
            result(FlutterError.init(code: "Error", message: "There is a problem with the parameters", details: nil))
         }
    }
    
    
}
