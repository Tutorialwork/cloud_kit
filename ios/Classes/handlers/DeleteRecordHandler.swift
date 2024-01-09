//
//  DeleteRecordHandler.swift
//  cloud_kit
//
//  Created by Manuel on 09.01.24.
//

import CloudKit

class DeleteRecordHandler: CommandHandler {
    
    var COMMAND_NAME: String = "DELETE_RECORD"
    
    func evaluateExecution(command: String) -> Bool {
        return command == COMMAND_NAME
    }
    
    func handle(command: String, arguments: Dictionary<String, Any>, result: @escaping FlutterResult) {
        if (!evaluateExecution(command: command)) {
            return
        }
        
        if let containerId: String = arguments["containerId"] as? String, let recordId: String = arguments["recordId"] as? String {
            let database: CKDatabase = CKContainer(identifier: containerId).privateCloudDatabase

            database.delete(withRecordID: CKRecord.ID(recordName: recordId)) { (recordId: CKRecord.ID?, error: Error?) in
                result(error == nil)
            }
         } else {
            result(FlutterError.init(code: "Error", message: "There is a problem with the parameters", details: nil))
         }
    }
    
    
}
