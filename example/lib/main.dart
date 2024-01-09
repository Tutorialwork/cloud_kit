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
  List<Record> records = [];

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
              (accountStatus != null) ? Text('Current account status: ${accountStatus}', textAlign: TextAlign.center,) : Container(),
              ElevatedButton(
                onPressed: () => cloudKit.saveRecord("User", {
                  "username": "Tutorialwork",
                  "password": "****"
                }),
                child: Text('Save Record'),
              ),
              ElevatedButton(
                onPressed: () async {
                  List<Record> records = await cloudKit.getRecords("User");

                  setState(() {
                    this.records = records;
                  });
                },
                child: Text('Get records'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    Record record = records[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text("User Record", style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(record.getValueForKey("username") ?? "Username unknown"),
                            Text(record.getValueForKey("password") ?? "Password unknown")
                          ],
                        ),
                        ElevatedButton(
                            onPressed: () => _updateRecord(records[index]),
                            child: Icon(Icons.edit)),
                        ElevatedButton(
                            onPressed: () => _deleteRecord(records[index]),
                            child: Icon(Icons.delete)),
                      ],
                    );
                  },
                ),
              )
            ],
          )),
    );
  }

  Future<void> _deleteRecord(Record record) async {
    bool status = await cloudKit.deleteRecord(record);
    print("Record was deleted with success status: $status");
  }

  Future<void> _updateRecord(Record record) async {
    record.setValueForKey("password", "test");
    bool status = await cloudKit.updateRecord(record);
    print("Updated record with success status: $status");
  }
}
