<div align="center">
    <img src="https://raw.githubusercontent.com/Tutorialwork/cloud_kit/main/images/logo.png" height="200">
</div>

# CloudKit

CloudKit is a simple Flutter package to access on iOS devices the iCloud using the Apple CloudKit Api.
You can save with the package key value pairs in the private database of the users iCloud.

# 📝 Usage

Just create a new instance of the CloudKit class with your container id of your created CloudKit container.
And then you are able, if the user is signed in into his iCloud account, to save key value pairs and delete it.

- Instantiate CloudKit instance to save and get a value.

```dart
CloudKit cloudKit = CloudKit('iCloud.dev.tutorialwork.cloudkitExample'); // Enter your container id
cloudKit.save('key', 'value');
cloudKit.get('key');
cloudKit.delete('key');
cloudKit.clearDatabase();
```

- Check if the user is logged in, otherwise the process of saving and getting value can fail.

```dart
CloudKitAccountStatus accountStatus = await cloudKit.getAccountStatus();
if (accountStatus == CloudKitAccountStatus.available) {
  // User is logged in with iCloud
}
```

# 💻 Setup

- Add the iCloud capability to your XCode project and tick all the three options and create with the plus icon a new CloudKit container and select it.

<div>
    <img src="https://raw.githubusercontent.com/Tutorialwork/cloud_kit/main/images/step1.png" height="300">
    <img src="https://raw.githubusercontent.com/Tutorialwork/cloud_kit/main/images/step2.png" height="300">
</div>

- Then it's important for the next step that you are creating your first entry. You can do this with the [example app](https://github.com/Tutorialwork/cloud_kit/tree/main/example) in this repository or with your own app by saving your first key value pair.

<img src="https://raw.githubusercontent.com/Tutorialwork/cloud_kit/main/images/step3.png" height="300">

- After that please open the [CloudKit Dashboard](https://icloud.developer.apple.com) and select your created CloudKit container and then open the "**Indexes**" page.
And select on these page the "**StorageItem**"

<img src="https://raw.githubusercontent.com/Tutorialwork/cloud_kit/main/images/step4.png" height="300">

- Click on "**Add Basic Index**" and select "**recordName**" and "**Queryable**" and then make sure you don't forgot to save your changes.

<img src="https://raw.githubusercontent.com/Tutorialwork/cloud_kit/main/images/step5.png" height="300">

- Make sure before you are deploying your app, you need to deploy the database schema using the "**Deploy Schema Changes…**" button.

<img src="https://raw.githubusercontent.com/Tutorialwork/cloud_kit/main/images/step6.png" height="300">
