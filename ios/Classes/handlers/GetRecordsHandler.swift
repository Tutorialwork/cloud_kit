//
//  GetRecordsHandler.swift
//  cloud_kit
//
//  Created by Manuel on 06.01.24.
//

import CloudKit

class GetRecordsHandler: CommandHandler {
    
    var COMMAND_NAME: String = "GET_RECORDS"
    
    func evaluateExecution(command: String) -> Bool {
        return command == COMMAND_NAME
    }
    
    func handle(command: String, arguments: Dictionary<String, Any>, result: @escaping FlutterResult) {
        if (!evaluateExecution(command: command)) {
            return
        }
        
        if let recordName: String = arguments["recordName"] as? String, let containerId: String = arguments["containerId"] as? String {
            let database: CKDatabase = CKContainer(identifier: containerId).privateCloudDatabase
            let query: CKQuery = CKQuery(recordType: recordName, predicate: NSPredicate(value: true))

            database.perform(query, inZoneWith: nil) { (records: [CKRecord]?, error: Error?) in
                if let records: [CKRecord] = records {
                    var recordsList: [CloudKitRecord] = []

                    records.forEach { (record: CKRecord) in
                        var values: Dictionary<String, String> = [String: String]()
                        
                        record.allKeys().forEach { (key: String) in
                            values[key] = record.value(forKey: key) as? String
                        }
                        
                        if let creationDate: Date = record.creationDate, let modificationDate: Date = record.modificationDate, let modifiedByDevice: String = record.value(forKey: "modifiedByDevice") as? String {
                            let isoFormatter: ISO8601DateFormatter = ISO8601DateFormatter()
                            let currentRecord: CloudKitRecord = CloudKitRecord(recordId: record.recordID.recordName,
                                                                               recordType: record.recordType,
                                                                               data: values,
                                                                               creationDate: isoFormatter.string(from: creationDate),
                                                                               modificationDate: isoFormatter.string(from: modificationDate),
                                                                               modifiedByDevice: modifiedByDevice)
                            recordsList.append(currentRecord)
                        }
                    }
                    
                    
                    do {
                        let json: Data = try JSONEncoder().encode(recordsList)
                        let jsonString: String = String(data: json, encoding: .utf8)!
                        
                        result(jsonString)
                    } catch { }
                }
            }
         } else {
            result(FlutterError.init(code: "Error", message: "There is a problem with the parameters", details: nil))
         }
    }
    
    
}
