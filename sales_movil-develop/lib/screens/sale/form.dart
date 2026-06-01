import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/providers/sale_provider.dart';

class SaleFormScreen extends StatefulWidget {
  const SaleFormScreen({super.key});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedClientId;
  int? _selectedProductId;
  final _quantityController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    context.read<SaleProvider>().loadFormData();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Venta'),
        backgroundColor: Colors.orange,
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: _selectedClientId,
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        border: OutlineInputBorder(),
                      ),
                      items: provider.clients.map((client) {
                        return DropdownMenuItem<int>(
                          value: client.serverId,
                          child: Text(client.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedClientId = value);
                      },
                      validator: (value) {
                        if (value == null) return 'Seleccione un cliente';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedProductId,
                      decoration: const InputDecoration(
                        labelText: 'Producto',
                        border: OutlineInputBorder(),
                      ),
                      items: provider.products.map((product) {
                        return DropdownMenuItem<int>(
                          value: product.id,
                          child: Text('${product.name} - S/ ${product.price.toStringAsFixed(2)}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedProductId = value);
                      },
                      validator: (value) {
                        if (value == null) return 'Seleccione un producto';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese una cantidad';
                        }
                        final qty = int.tryParse(value.trim());
                        if (qty == null || qty < 1) {
                          return 'Cantidad debe ser 1 o más';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        final success = await context
                            .read<SaleProvider>()
                            .create(
                              _selectedClientId!,
                              _selectedProductId!,
                              int.parse(_quantityController.text.trim()),
                            );

                        if (!mounted) return;

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Venta registrada')),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al registrar venta'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Registrar Venta'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}