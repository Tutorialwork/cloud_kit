//
//  FetchAllHandler.swift
//  cloud_kit
//
//  Created by Manuel on 07.04.23.
//

class FetchAllHandler: CommandHandler {
    
    var COMMAND_NAME: String = "FETCH_ALL"
    
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
            let recordType = arguments["recordType"] as? String,
            let containerId = arguments["containerId"] as? String {
            
            let defaultContainer: CKContainer = CKContainer(identifier: containerId)
            let database = defaultContainer.privateCloudDatabase
            
            defaultContainer.accountStatus { (accountStatus: CKAccountStatus, error: Any?) in
                if (error != nil) {
                    result(FlutterError.init(code: "Error", message: "Can't fetch account status", details: nil))
                    return
                }
            }
            
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: recordType, predicate: predicate)
            
            database.perform(query, inZoneWith: nil) { (records, error) in
                if let error = error {
                    result(FlutterError.init(code: "Error", message: "\(error)", details: nil))
                    return
                }
                guard let records = records else {
                    result(FlutterError.init(code: "Error", message: "No records found", details: nil))
                    return
                }
                var jsonRecords: [[String: Any]] = []
                for record in records {
                    let jsonRecord = toDictionary(record: record)
                    jsonRecords.append(jsonRecord)
                }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonRecords, options: [])
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        result(jsonString)
                    } else {
                        result(FlutterError.init(code: "Error", message: "Failed to convert data to string", details: nil))
                    }
                } catch {
                    result(FlutterError.init(code: "Error", message: "\(error)", details: nil))
                }
            }
        } else {
            result(FlutterError.init(code: "Error", message: "Cannot missing Arguments", details: nil))
        }
    }
    
    
}
