//
//  CloudKitRecord.swift
//  cloud_kit
//
//  Created by Manuel on 07.01.24.
//

struct CloudKitRecord: Encodable {
    
    let recordId: String
    let recordType: String
    let data: Dictionary<String, String>
    let creationDate: String
    let modificationDate: String
    let modifiedByDevice: String
    
}
