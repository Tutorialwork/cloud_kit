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
              decoration: InputDecoration(
                hintText: 'Key'
              ),
            ),
            TextFormField(
              controller: value,
              decoration: InputDecoration(
                  hintText: 'Value'
              ),
            ),
            ElevatedButton(
              onPressed: () => cloudKit.save(key.text, value.text),
              child: Text('Save'),
            ),
            ElevatedButton(
              onPressed: () async {
                value.text = await cloudKit.get(key.text);

                setState(() {

                });
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
            )
          ],
        )
      ),
    );
  }
}
