import 'package:flutter/material.dart';
import 'package:provider/provider.dart' hide Provider;
import 'package:sales/models/provider.dart';
import 'package:sales/providers/provider_provider.dart';
import 'package:sales/screens/provider/form.dart';

class ProviderDetailScreen extends StatefulWidget {
  final Provider provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  late Provider _provider;

  @override
  void initState() {
    super.initState();
    _provider = widget.provider;
  }

  Future<void> _eliminar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar proveedor'),
        content: const Text('¿Estás seguro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<ProviderProvider>().delete(_provider);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Proveedor'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProviderFormScreen(provider: _provider),
                ),
              );
              if (!mounted) return;
              context.read<ProviderProvider>().loadAll();
              final providers = context.read<ProviderProvider>().providers;
              final updated = providers.where((p) => p.id == _provider.id);
              if (updated.isNotEmpty) {
                setState(() => _provider = updated.first);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                _provider.isSynced ? Icons.cloud_done : Icons.cloud_off,
                size: 64,
                color: _provider.isSynced ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _provider.isSynced ? 'Sincronizado' : 'Pendiente',
                style: TextStyle(
                  fontSize: 16,
                  color: _provider.isSynced ? Colors.green : Colors.red,
                ),
              ),
            ),
            const Divider(height: 32),
            Text('ID: ${_provider.id}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Nombre: ${_provider.name}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('RUC: ${_provider.ruc}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Teléfono: ${_provider.phone}',
                style: const TextStyle(fontSize: 16)),
            if (_provider.serverId != null) ...[
              const SizedBox(height: 8),
              Text('Server ID: ${_provider.serverId}',
                  style: const TextStyle(fontSize: 16)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _eliminar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Eliminar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}