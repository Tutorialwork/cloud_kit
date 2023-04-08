enum CloudKitAccountStatus {
  /// CloudKit can’t determine the status of the user’s iCloud account.
  couldNotDetermine(0),

  /// The user’s iCloud account is available.
  available(1),

  /// The system denies access to the user’s iCloud account.
  restricted(2),

  /// The device doesn’t have an iCloud account.
  noAccount(3),

  /// Not possible to determine status because the device is not running iOS
  notSupported(99);

  const CloudKitAccountStatus(this.value);
  final num value;
}
