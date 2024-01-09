import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'types/CloudKitAccountStatus.dart';
import 'types/record.dart';
import 'types/record_entry.dart';

export 'types/CloudKitAccountStatus.dart';
export 'types/record.dart';
export 'types/record_entry.dart';

/// A Wrapper for CloudKit
class CloudKit {
  static const MethodChannel _channel = const MethodChannel('cloud_kit');

  String _containerId = '';

  CloudKit(String containerIdentifier) {
    _containerId = containerIdentifier;
  }

  /// Save a new entry to CloudKit using a key and value.
  /// The key need to be unique.
  /// Returns a boolean [bool] with true if the save was successfully.
  Future<bool> save(String key, String value) async {
    if (!Platform.isIOS) {
      return false;
    }

    if (key.length == 0 || value.length == 0) {
      return false;
    }

    bool status = await _channel.invokeMethod('SAVE_VALUE',
            {"key": key, "value": value, "containerId": _containerId}) ??
        false;

    return status;
  }

  /// Loads a value from CloudKit by key.
  /// Returns a string [string] with the saved value.
  /// This can be null if the key was not found.
  Future<String?> get(String key) async {
    if (!Platform.isIOS) {
      return null;
    }

    if (key.length == 0) {
      return null;
    }

    List<dynamic> records = await (_channel
        .invokeMethod('GET_VALUE', {"key": key, "containerId": _containerId}));

    if (records.length != 0) {
      return records[0];
    } else {
      return null;
    }
  }

  /// Delete a entry from CloudKit using the key.
  Future<bool> delete(String key) async {
    if (!Platform.isIOS) {
      return false;
    }

    if (key.length == 0) {
      return false;
    }

    bool success = await _channel.invokeMethod('DELETE_VALUE', {
          "key": key,
          "containerId": _containerId,
        }) ??
        false;

    return success;
  }

  /// Deletes the entire user database.
  Future<bool> clearDatabase() async {
    if (!Platform.isIOS) {
      return false;
    }

    bool success = await _channel
            .invokeMethod('DELETE_ALL', {"containerId": _containerId}) ??
        false;

    return success;
  }

  /// Gets the iCloud account status
  /// This is useful to check first if the user is logged in
  /// and then trying to save data to the users iCloud
  Future<CloudKitAccountStatus> getAccountStatus() async {
    if (!Platform.isIOS) {
      return CloudKitAccountStatus.notSupported;
    }

    int accountStatus = await _channel
        .invokeMethod('GET_ACCOUNT_STATUS', {"containerId": _containerId});

    return CloudKitAccountStatus.values[accountStatus];
  }

  Future<bool> saveRecord(String name, Map<String, dynamic> values) async {
    if (!Platform.isIOS) {
      return false;
    }

    if (name.length == 0 || values.length == 0) {
      return false;
    }

    bool status = await _channel.invokeMethod('SAVE_RECORD',
        {"recordName": name, "values": values, "containerId": _containerId}) ??
        false;

    return status;
  }

  Future<List<Record>> getRecords(String name) async {
    if (!Platform.isIOS) {
      return [];
    }

    if (name.length == 0) {
      return [];
    }

    String recordsJson = await (_channel
        .invokeMethod('GET_RECORDS', {"recordName": name, "containerId": _containerId}));

    List<Record> recordsList = [];
    List<dynamic> records = jsonDecode(recordsJson);

    records.forEach((dynamic recordData) {
      List<MapEntry<Object?, Object?>> resultList = recordData["data"].entries.toList();
      List<RecordEntry> recordEntries = [];

      resultList.forEach((MapEntry<Object?, Object?> entry) {
        RecordEntry recordEntry = new RecordEntry(entry.key as String, entry.value as String);
        recordEntries.add(recordEntry);
      });

      Record record = new Record(recordData["recordId"], recordData["recordType"], DateTime.parse(recordData["creationDate"]), DateTime.parse(recordData["modificationDate"]), recordData["modifiedByDevice"], recordEntries);
      recordsList.add(record);
    });

    return recordsList;
  }

  Future<bool> deleteRecord(Record record) async {
    if (!Platform.isIOS) {
      return false;
    }

    bool status = await _channel.invokeMethod('DELETE_RECORD', {"recordId": record.recordId, "containerId": _containerId});

    return status;
  }
}
