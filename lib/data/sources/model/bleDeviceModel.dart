class BleDeviceModel {
  final String id;

  final String name;

  final int rssi;

  final DateTime lastSeen;

  BleDeviceModel({
    required this.id,
    required this.name,
    required this.rssi,
    required this.lastSeen,
  });

  BleDeviceModel copyWith({String? name, int? rssi, DateTime? lastSeen}) {
    return BleDeviceModel(
      id: id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'rssi': rssi,
    'last_seen': lastSeen.millisecondsSinceEpoch,
  };

  factory BleDeviceModel.fromMap(Map<String, dynamic> map) => BleDeviceModel(
    id: map['id'],
    name: map['name'],
    rssi: map['rssi'],
    lastSeen: DateTime.fromMillisecondsSinceEpoch(map['last_seen']),
  );
}
