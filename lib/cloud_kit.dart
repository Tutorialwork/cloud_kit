import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CloudKit {
  static const MethodChannel _channel = const MethodChannel('cloud_kit');

  String _containerId = '';
  String _recordType = '';
  static const String _defaultRecordType = 'default';

  CloudKit(String containerIdentifier,
      {String recordType = _defaultRecordType}) {
    _containerId = containerIdentifier;
    _recordType = recordType;
  }

  Future<bool> check() async {
    if (!Platform.isIOS) {
      return false;
    }

    bool status = await _channel.invokeMethod('check', {}) ?? false;
    return status;
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

    bool status = await _channel.invokeMethod('save', {
          "key": key,
          "value": value,
          "containerId": _containerId,
          "recordType": _recordType
        }) ??
        false;

    return status;
  }

  Future<bool> saveRecord(Map<String, String> data,
      {String withRecordType = _defaultRecordType}) async {
    if (!Platform.isIOS) {
      return false;
    }
    final recordType = _recordType != '' ? _recordType : withRecordType;

    bool status = await _channel.invokeMethod('saveRecord', {
          "data": data,
          "containerId": _containerId,
          "recordType": recordType
        }) ??
        false;

    return status;
  }

  Future<List<Map<String, String>>> getRecords(
      {String withRecordType = _defaultRecordType}) async {
    if (!Platform.isIOS) {
      return [];
    }
    final recordType = _recordType != '' ? _recordType : withRecordType;

    List<Map<String, String>> records = await _channel.invokeMethod(
            'getRecords',
            {"containerId": _containerId, "recordType": recordType}) ??
        [];
    return records;
  }

  Future<void> deleteRecord(String key,
      {String withRecordType = _defaultRecordType}) {
    final recordType = _recordType != '' ? _recordType : withRecordType;
    return _channel.invokeMethod('deleteRecord',
        {"containerId": _containerId, "recordType": recordType, "key": key});
  }

  Future<List<String>> getKeys() async {
    if (!Platform.isIOS) {
      return [];
    }

    try {
      List<dynamic> records = await (_channel.invokeMethod(
          'getKeys', {"containerId": _containerId, "recordType": _recordType}));
      return records.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
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

    List<dynamic> records = await (_channel.invokeMethod('get',
        {"key": key, "containerId": _containerId, "recordType": _recordType}));

    if (records.length != 0) {
      return records[0];
    } else {
      return null;
    }
  }

  /// Delete a entry from CloudKit using the key.
  Future<void> delete(String key) async {
    if (!Platform.isIOS) {
      return;
    }

    if (key.length == 0) {
      return;
    }

    await _channel.invokeMethod('delete',
        {"key": key, "containerId": _containerId, "recordType": _recordType});
  }

  /// Deletes the entire user database.
  Future<void> clearDatabase() async {
    if (!Platform.isIOS) {
      return;
    }

    await _channel.invokeMethod('deleteAll', {"containerId": _containerId});
  }
}
