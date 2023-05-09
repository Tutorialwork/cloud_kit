//
//  FetchObjectHandler.swift
//  cloud_kit
//
//  Created by Mohammad on 09.05.23.
//

class FetchObjectHandler: CommandHandler {
    
    var COMMAND_NAME: String = "FETCH_OBJECT"
    
    func evaluateExecution(command: String) -> Bool {
        return command == COMMAND_NAME
    }
    
    func toDictionary(record: CKRecord) -> [String: Any] {
        var dictionary = [String: Any]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        
        for (key, value) in record {
            if let date = value as? Date {
                dictionary[key] = dateFormatter.string(from: date)
            } else {
                dictionary[key] = value
            }
        }
        
        return dictionary
    }

    func toJsonString(record: CKRecord) -> String? {
        do {
            // Convert the record to a dictionary
            let dictionary = try toDictionary(record: record)
            
            // Serialize the dictionary to a JSON string
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error converting record to JSON string: \(error.localizedDescription)")
        }
        
        return nil
    }

    func handle(command: String, arguments: Dictionary<String, Any>, result: @escaping FlutterResult) {
        if (!evaluateExecution(command: command)) {
            return
        }
        if let arguments = call.arguments as? Dictionary<String, Any>,
            let id = arguments["id"] as? String,
            let containerId = arguments["containerId"] as? String {
            
            let defaultContainer: CKContainer = CKContainer(identifier: containerId)
            let database = defaultContainer.privateCloudDatabase
            defaultContainer.accountStatus { (accountStatus: CKAccountStatus, error: Any?) in
                if (error != nil) {
                    result(FlutterError.init(code: "Error", message: "Can't fetch account status", details: nil))
                    return
                }
            }
            let recordID = CKRecord.ID(recordName: "\(id)")
            database.fetch(withRecordID: recordID) { (record, error) in
                if let error = error {
                    print("Error fetching record: \(error)")
                    result(FlutterError.init(code: "Error", message: "Error fetching record: \(error)", details: nil))
                    return
                    
                } else if var record = record {
                    //return json
                    let jsonString = toJsonString(record: record)
                    print(jsonString)
                    result(jsonString)
                }
            }
            
        } else {
            result(FlutterError.init(code: "Error", message: "Cannot missing Arguments", details: nil))
        }
    }
    
    
}
