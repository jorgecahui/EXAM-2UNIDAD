import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/providers/sale_provider.dart';
import 'package:sales/screens/sale/form.dart';

class SaleListScreen extends StatefulWidget {
  const SaleListScreen({super.key});

  @override
  State<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends State<SaleListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SaleProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SaleProvider>();
    final sales = provider.sales;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Ventas'),
        backgroundColor: Colors.orange,
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SaleFormScreen()),
          );
          if (!mounted) return;
          context.read<SaleProvider>().loadAll();
        },
        child: const Icon(Icons.add),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : sales.isEmpty
              ? const Center(child: Text('No hay ventas registradas'))
              : ListView.builder(
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: ListTile(
                        title: Text('Cliente: ${sale.clientName}'),
                        subtitle: Text(
                            'Producto: ${sale.productName}\nTotal: S/ ${sale.total.toStringAsFixed(2)}'),
                        isThreeLine: true,
                        trailing:
                            Text(sale.createdAt.substring(0, 10)),
                      ),
                    );
                  },
                ),
    );
  }
}