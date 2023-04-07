//
//  CommandHandler.swift
//  cloud_kit
//
//  Created by Manuel on 07.04.23.
//

protocol CommandHandler {
    var COMMAND_NAME: String { get }
    func evaluateExecution(command: String) -> Bool
    func handle(command: String, arguments: Dictionary<String, Any>, result: @escaping FlutterResult) -> Void
}
