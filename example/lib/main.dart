import 'package:flutter/material.dart';

import 'package:cloud_kit/cloud_kit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController key = TextEditingController();
  TextEditingController value = TextEditingController();
  CloudKit cloudKit = CloudKit("iCloud.dev.tutorialwork.cloudkitExample");
  CloudKitAccountStatus? accountStatus;
  Map<String, String>? allKeysAndValues;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            children: [
              TextFormField(
                controller: key,
                decoration: InputDecoration(hintText: 'Key'),
              ),
              TextFormField(
                controller: value,
                decoration: InputDecoration(hintText: 'Value'),
              ),
              ElevatedButton(
                onPressed: () async {
                  bool success = await cloudKit.save(key.text, value.text);
                  if (success) {
                    print('Successfully saved key ' + key.text);
                  } else {
                    print('Failed to save key: ' + key.text);
                  }
                },
                child: Text('Save'),
              ),
              ElevatedButton(
                onPressed: () async {
                  value.text = await cloudKit.get(key.text) ?? '';

                  setState(() {});
                },
                child: Text('Get'),
              ),
              ElevatedButton(
                onPressed: () => cloudKit.delete(key.text),
                child: Text('Delete'),
              ),
              ElevatedButton(
                onPressed: () => cloudKit.clearDatabase(),
                child: Text('Clear Database'),
              ),
              ElevatedButton(
                onPressed: () async {
                  accountStatus = await cloudKit.getAccountStatus();
                  setState(() {

                  });
                },
                child: Text('Get account status'),
              ),
              (accountStatus != null) ? Text('Current account status: \n ${accountStatus}', textAlign: TextAlign.center,) : Container(),
              ElevatedButton(
                onPressed: () async {
                  allKeysAndValues = await cloudKit.getAll();
                  setState(() {

                  });
                },
                child: Text('Get all keys and values'),
              ),
              (allKeysAndValues != null) ? Text('All saved keys and values: \n ${_getKeysAndValuesAsString(allKeysAndValues)}', textAlign: TextAlign.center,) : Container()
            ],
          )),
    );
  }

  String _getKeysAndValuesAsString(Map<String, String>? keysAndValues) {
    if (keysAndValues == null) {
      return "";
    }
    String result = "";
    keysAndValues.forEach((key, value) {
      result += key + " = " + value + "\n";
    });
    return result;
  }
}
