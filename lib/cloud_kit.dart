// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

    final map =
        Map<String, dynamic>.from(await _channel.invokeMethod('check', {}));

    final response = SwiftResponse.fromMap(map);

    return response.success;
  }

  /// Save a new entry to CloudKit using a key and value.
  /// The key need to be unique.
  /// Returns a boolean [bool] with true if the save was successfully.
  Future<bool> save(String key, String value, String version) async {
    if (!Platform.isIOS) {
      return false;
    }

    if (key.length == 0 || value.length == 0 || version.length == 0) {
      return false;
    }

    final map = Map<String, dynamic>.from(await _channel.invokeMethod('save', {
      "key": key,
      "value": value,
      "version": version,
      "containerId": _containerId,
      "recordType": _recordType
    }));

    final response = SwiftResponse.fromMap(map);

    return response.success;
  }

  Future<bool> saveRecord(Map<String, String> data,
      {String? withRecordType}) async {
    if (!Platform.isIOS) {
      return false;
    }

    final map =
        Map<String, dynamic>.from(await _channel.invokeMethod('saveRecord', {
      "data": data,
      "containerId": _containerId,
      "recordType": withRecordType ?? _recordType
    }));

    final response = SwiftResponse.fromMap(map);
    return response.success;
  }

  Future<List> getRecords({String? withRecordType}) async {
    if (!Platform.isIOS) {
      return [];
    }
    try {
      final map = Map<String, dynamic>.from(await _channel.invokeMethod(
          'getRecords', {
        "containerId": _containerId,
        "recordType": withRecordType ?? _recordType
      }));

      final response = SwiftResponse.fromMap(map);
      if (response.success) {
        final records = response.data as List<dynamic>;
        return records.map((e) => jsonEncode(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteRecord(String key, {String? withRecordType}) {
    return _channel.invokeMethod('deleteRecord', {
      "containerId": _containerId,
      "recordType": withRecordType ?? _recordType,
      "key": key
    });
  }

  Future<List<String>> getKeys() async {
    if (!Platform.isIOS) {
      return [];
    }

    try {
      final map = Map<String, dynamic>.from(await (_channel.invokeMethod(
          'getKeys',
          {"containerId": _containerId, "recordType": _recordType})));
      final response = SwiftResponse.fromMap(map);
      if (response.success) {
        final records = response.data as List<dynamic>;
        return records.map((e) => e.toString()).toList();
      } else {
        return [];
      }
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

    final map = Map<String, dynamic>.from(await (_channel.invokeMethod('get',
        {"key": key, "containerId": _containerId, "recordType": _recordType})));
    final response = SwiftResponse.fromMap(map);

    if (response.success) {
      final data = response.data as List<dynamic>;
      if (data.isNotEmpty) {
        return response.data[0];
      }
      return null;
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

class SwiftResponse {
  bool success;
  String? error;
  dynamic data;

  SwiftResponse(this.success, this.error, this.data);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'success': success,
      'error': error,
      'data': data,
    };
  }

  factory SwiftResponse.fromMap(Map<String, dynamic> map) {
    return SwiftResponse(
      map['success'] as bool,
      map['error'] != null ? map['error'] as String : null,
      map['data'] as dynamic,
    );
  }

  String toJson() => json.encode(toMap());

  factory SwiftResponse.fromJson(String source) =>
      SwiftResponse.fromMap(json.decode(source) as Map<String, dynamic>);
}
