import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:sales/config/app_config.dart';
import 'package:sales/models/provider.dart';

enum SyncResult { created, updated, duplicate, error }

class ProviderService {
  final String apiUrl = AppConfig.apiUrl;

  Future<(SyncResult, int?)> save(Provider provider) async {
    var url = Uri.http(apiUrl, '/provider/providers/');

    var response = await http.post(
      url,
      body: convert.jsonEncode(provider.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      final json = convert.jsonDecode(response.body);
      return (SyncResult.created, json['id'] as int);
    }
    if (response.statusCode == 400) {
      final serverId = await _findServerIdByRuc(provider.ruc);
      return (SyncResult.duplicate, serverId);
    }
    return (SyncResult.error, null);
  }

  Future<int?> _findServerIdByRuc(String ruc) async {
    try {
      var url = Uri.http(apiUrl, '/provider/providers/', {'ruc': ruc});
      var response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = convert.jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data[0]['id'] as int;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<SyncResult> edit(Provider provider) async {
    var url = Uri.http(apiUrl, '/provider/providers/${provider.serverId}/');

    var response = await http.put(
      url,
      body: convert.jsonEncode(provider.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) return SyncResult.updated;
    return SyncResult.error;
  }

  Future<void> delete(int serverId) async {
    var url = Uri.http(apiUrl, '/provider/providers/$serverId/');
    var response = await http.delete(url);
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar proveedor');
    }
  }
}