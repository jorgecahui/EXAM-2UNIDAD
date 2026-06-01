import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/providers/provider_provider.dart';
import 'package:sales/screens/provider/form.dart';
import 'package:sales/screens/provider/detail.dart';

class ProviderListScreen extends StatefulWidget {
  const ProviderListScreen({super.key});

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    context.read<ProviderProvider>().loadAll();
  }

  Future<void> _sincronizar() async {
    setState(() => _syncing = true);

    final result = await context.read<ProviderProvider>().sincronizar();

    if (!mounted) return;

    setState(() => _syncing = false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sincronización completa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Creados: ${result['sincronizados']}'),
            Text('🔄 Actualizados: ${result['actualizados']}'),
            Text('⚠️ Ya existían: ${result['duplicados']}'),
            Text('❌ Errores: ${result['errores']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmarEliminar(BuildContext context) async {
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
    return confirm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final providers = context.watch<ProviderProvider>().providers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Proveedores'),
        backgroundColor: Colors.orange,
        actions: [
          _syncing
              ? const Padding(
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(color: Colors.white),
          )
              : IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar',
            onPressed: _sincronizar,
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProviderFormScreen()),
          );
          if (!mounted) return;
          context.read<ProviderProvider>().loadAll();
        },
        child: const Icon(Icons.add),
      ),
      body: providers.isEmpty
          ? const Center(child: Text('No hay proveedores registrados'))
          : ListView.builder(
        itemCount: providers.length,
        itemBuilder: (context, index) {
          final provider = providers[index];
          return Dismissible(
            key: Key(provider.id.toString()),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => _confirmarEliminar(context),
            onDismissed: (_) async {
              await context.read<ProviderProvider>().delete(provider);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              leading: Icon(
                provider.isSynced ? Icons.cloud_done : Icons.cloud_off,
                color: provider.isSynced ? Colors.green : Colors.red,
              ),
              title: Text(provider.name),
              subtitle: Text('RUC: ${provider.ruc}'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProviderDetailScreen(provider: provider),
                  ),
                );
                if (!mounted) return;
                context.read<ProviderProvider>().loadAll();
              },
            ),
          );
        },
      ),
    );
  }
}