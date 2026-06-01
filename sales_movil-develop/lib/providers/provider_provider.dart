import 'package:flutter/material.dart';
import 'package:sales/database/database_helper.dart';
import 'package:sales/models/provider.dart';
import 'package:sales/services/provider_service.dart';

class ProviderProvider extends ChangeNotifier {
  List<Provider> _providers = [];

  List<Provider> get providers => _providers;

  final DatabaseHelper _db = DatabaseHelper();
  final ProviderService _service = ProviderService();
  final String _table = DatabaseHelper.tableProviders;

  Future<void> loadAll() async {
    final rows = await _db.queryAll(_table);
    _providers = rows.map((row) => Provider.fromMap(row)).toList();
    notifyListeners();
  }

  Future<void> save(Provider provider) async {
    await _db.insert(_table, provider.toMap());
    await loadAll();
  }

  Future<void> edit(int id, Provider provider) async {
    await _db.update(_table, id, {
      'name': provider.name,
      'ruc': provider.ruc,
      'phone': provider.phone,
      'is_synced': 0,
      'server_id': provider.serverId,
    });
    await loadAll();
  }

  Future<void> delete(Provider provider) async {
    if (provider.isSynced && provider.serverId != null) {
      await _service.delete(provider.serverId!);
    }
    await _db.delete(_table, provider.id);
    await loadAll();
  }

  Future<Map<String, int>> sincronizar() async {
    int sincronizados = 0;
    int actualizados = 0;
    int duplicados = 0;
    int errores = 0;

    try {
      final rows = await _db.queryPending(_table);
      final pending = rows.map((row) => Provider.fromMap(row)).toList();

      for (final provider in pending) {
        try {
          if (provider.serverId == null) {
            final (result, serverId) = await _service.save(provider);
            if (result == SyncResult.created && serverId != null) {
              await _db.updateSynced(_table, provider.id, serverId);
              sincronizados++;
            } else if (result == SyncResult.duplicate && serverId != null) {
              await _db.updateSynced(_table, provider.id, serverId);
              duplicados++;
            } else if (result == SyncResult.duplicate) {
              duplicados++;
            } else {
              errores++;
            }
          } else {
            final result = await _service.edit(provider);
            if (result == SyncResult.updated) {
              await _db.updateSyncedOnly(_table, provider.id);
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