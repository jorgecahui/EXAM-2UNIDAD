class Provider {
  final int id;
  final String name;
  final String ruc;
  final String phone;
  final bool isSynced;
  final int? serverId;

  Provider(this.id, this.name, this.ruc, this.phone, this.isSynced, this.serverId);

  factory Provider.fromMap(Map<String, dynamic> map) {
    return Provider(
      map['id'],
      map['name'].toString(),
      map['ruc'].toString(),
      map['phone'].toString(),
      map['is_synced'] == 1,
      map['server_id'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'name': name,
      'ruc': ruc,
      'phone': phone,
      'is_synced': isSynced ? 1 : 0,
      'server_id': serverId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ruc': ruc,
      'phone': phone,
    };
  }
}