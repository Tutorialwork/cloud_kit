import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'types/CloudKitAccountStatus.dart';
export 'types/CloudKitAccountStatus.dart';

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

  /// Loads all values stored in CloudKit in a Map with key and value both as a string
  Future<Map<String, String>?> getAll() async {
    if (!Platform.isIOS) {
      return null;
    }

    Map<dynamic, dynamic> records = await (_channel
        .invokeMethod('GET_ALL_VALUE', {"containerId": _containerId}));

    Map<String, String> stringRecords = records.map((key, value) {
      return MapEntry(key.toString(), value.toString());
    });

    return stringRecords;
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
}
