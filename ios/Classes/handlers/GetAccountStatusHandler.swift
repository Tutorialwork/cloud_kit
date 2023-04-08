//
//  GetAccountStatusHandler.swift
//  cloud_kit
//
//  Created by Manuel on 08.04.23.
//

import CloudKit

class GetAccountStatusHandler: CommandHandler {
    var COMMAND_NAME: String = "GET_ACCOUNT_STATUS"
    
    func evaluateExecution(command: String) -> Bool {
        return command == COMMAND_NAME
    }
    
    func handle(command: String, arguments: Dictionary<String, Any>, result: @escaping FlutterResult) {
        if (!evaluateExecution(command: command)) {
            return
        }
        
        if let containerId = arguments["containerId"] as? String {
            let defaultContainer: CKContainer = CKContainer(identifier: containerId)
            defaultContainer.accountStatus { (accountStatus: CKAccountStatus, error: Any?) in
                if (error != nil) {
                    result(FlutterError.init(code: "Error", message: "Can't fetch account status", details: nil))
                    return
                }

                result(accountStatus.rawValue)
            }
            
        } else {
            result(FlutterError.init(code: "Error", message: "Failed to parse arguments", details: nil))
        }
    }
    
    
}
