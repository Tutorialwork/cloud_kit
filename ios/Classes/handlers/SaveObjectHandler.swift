//
//  SaveObjectHandler.swift
//  cloud_kit
//
//  Created by Mohammad on 09.05.23.
//

class SaveObjectHandler: CommandHandler {
    
    var COMMAND_NAME: String = "SAVE_OBJECT"
    
    func evaluateExecution(command: String) -> Bool {
        return command == COMMAND_NAME
    }
    
    func fromDictionary(dictionary: [String: Any], record: inout CKRecord) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        
        for (key, value) in dictionary {
            if value is NSNull {
                record.setValue("", forKey: key)
            } else if let dateString = value as? String,
                    let date = dateFormatter.date(from: dateString) {
                record.setValue(date, forKey: key)
            } else {
                record.setValue(value, forKey: key)
            }
            // do something with each key-value pair
        }
    }

    func handle(command: String, arguments: Dictionary<String, Any>, result: @escaping FlutterResult) {
        if (!evaluateExecution(command: command)) {
            return
        }
        if let arguments = call.arguments as? Dictionary<String, Any>,
            let recordType = arguments["recordType"] as? String,
            let jsonString = arguments["json"] as? String,
            let containerId = arguments["containerId"] as? String {
            
            let defaultContainer: CKContainer = CKContainer(identifier: containerId)
            let database = defaultContainer.privateCloudDatabase
            
            defaultContainer.accountStatus { (accountStatus: CKAccountStatus, error: Any?) in
                if (error != nil) {
                    result(FlutterError.init(code: "Error", message: "Can't fetch account status", details: nil))
                    return
                }
            }
            
            guard let jsonData = jsonString.data(using: .utf8),
                    let jsonObject = try? JSONSerialization.jsonObject(with: jsonData),
                    let dictionary = jsonObject as? [String: Any] else {
                result(FlutterError.init(code: "Error", message: "Failed to convert the JSON string into Data", details: nil))
                return
            }
            
            do {
                if !dictionary.contains(where: { $0.key == "id" }) {
                    result(FlutterError.init(code: "Error", message: "Data Missing Id", details: nil))
                    return
                }
                let recordID = CKRecord.ID(recordName: "\(dictionary["id"] ?? "")")
                
                database.fetch(withRecordID: recordID) { (record, error) in
                    if let error = error {
                        // Create new Recoord
                        
                        var record = CKRecord(recordType: recordType ,recordID: recordID)
                        fromDictionary(dictionary: dictionary, record: &record)
                        
                        database.save(record) { (record, error) in
                            if record != nil, error == nil {
                                result(true)
                            } else {
                                result(false)
                            }
                        }
                        
                    } else if var record = record {
                        // Update the record's values
                        
                        fromDictionary(dictionary: dictionary, record: &record)
                        
                        // Save the updated record to the database
                        database.save(record) { (record, error) in
                            if record != nil, error == nil {
                                result(true)
                            } else {
                                result(false)
                            }
                        }
                    }
                }
            } catch {
                result(FlutterError.init(code: "Error", message: "\(error)", details: nil))
                return
            }
            
        } else {
            result(FlutterError.init(code: "Error", message: "Cannot missing Arguments", details: nil))
        }
    }
    
    
}
