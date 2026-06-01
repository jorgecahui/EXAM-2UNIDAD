import 'package:flutter/material.dart';
import 'package:sales/database/database_helper.dart';
import 'package:sales/models/client.dart';
import 'package:sales/services/client_service.dart';

class ClientProvider extends ChangeNotifier {
  List<Client> _clients = [];

  List<Client> get clients => _clients;

  final DatabaseHelper _db = DatabaseHelper();
  final ClientService _service = ClientService();

  final String _table = DatabaseHelper.tableClients;

  Future<void> loadAll() async {
    final rows = await _db.queryAll(_table);
    _clients = rows.map((row) => Client.fromMap(row)).toList();
    notifyListeners();
  }

  Future<void> save(Client client) async {
    await _db.insert(_table, client.toMap());
    await loadAll();
  }

  Future<void> edit(int id, Client client) async {
    await _db.update(_table, id, {
      'name': client.name,
      'document_number': client.documentNumber,
      'is_synced': 0,
      'server_id': client.serverId,
    });
    await loadAll();
  }

  Future<void> delete(Client client) async {
    if (client.isSynced && client.serverId != null) {
      await _service.delete(client.serverId!);
    }
    await _db.delete(_table, client.id);
    await loadAll();
  }

  Future<Map<String, int>> sincronizar() async {
    int sincronizados = 0;
    int actualizados = 0;
    int duplicados = 0;
    int errores = 0;

    try {
      final rows = await _db.queryPending(_table);
      final pending = rows.map((row) => Client.fromMap(row)).toList();

      for (final client in pending) {
        try {
          if (client.serverId == null) {
            final (result, serverId) = await _service.save(client);
            if (result == SyncResult.created && serverId != null) {
              await _db.updateSynced(_table, client.id, serverId);
              sincronizados++;
            } else if (result == SyncResult.duplicate && serverId != null) {
              await _db.updateSynced(_table, client.id, serverId);
              duplicados++;
            } else if (result == SyncResult.duplicate) {
              duplicados++;
            } else {
              errores++;
            }
          } else {
            final result = await _service.edit(client);
            if (result == SyncResult.updated) {
              await _db.updateSyncedOnly(_table, client.id);
              actualizados++;
            } else {
              errores++;
            }
          }
        } catch (_) {
          errores++;
        }
      }
    } catch (_) {
      errores = 1;
    }

    await loadAll();
    return {
      'sincronizados': sincronizados,
      'actualizados': actualizados,
      'duplicados': duplicados,
      'errores': errores,
    };
  }
}