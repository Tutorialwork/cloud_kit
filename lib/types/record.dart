import 'record_entry.dart';

class Record {
  String recordId;
  String recordType;
  DateTime creationDate;
  DateTime modificationDate;
  String modifiedByDevice;
  List<RecordEntry> recordEntries;

  Record(this.recordId, this.recordType, this.creationDate,
      this.modificationDate, this.modifiedByDevice, this.recordEntries);

  String? getValueForKey(String key) {
    return this.recordEntries.where((RecordEntry entry) => entry.key == key).toList()[0].value;
  }
}