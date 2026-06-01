import 'package:flutter/material.dart';
import 'package:provider/provider.dart' hide Provider;
import 'package:sales/models/provider.dart';
import 'package:sales/providers/provider_provider.dart';

class ProviderFormScreen extends StatefulWidget {
  final Provider? provider;

  const ProviderFormScreen({super.key, this.provider});

  @override
  State<ProviderFormScreen> createState() => _ProviderFormScreenState();
}

class _ProviderFormScreenState extends State<ProviderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerRuc = TextEditingController();
  TextEditingController controllerPhone = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = widget.provider;
    if (provider != null) {
      controllerName.text = provider.name;
      controllerRuc.text = provider.ruc;
      controllerPhone.text = provider.phone;
    }
  }

  @override
  void dispose() {
    controllerName.dispose();
    controllerRuc.dispose();
    controllerPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.provider != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Proveedor' : 'Formulario de Proveedor'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: controllerName,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: controllerRuc,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'RUC',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El RUC es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: controllerPhone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El teléfono es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  if (isEditing) {
                    await context.read<ProviderProvider>().edit(
                      widget.provider!.id,
                      Provider(
                        widget.provider!.id,
                        controllerName.text.trim(),
                        controllerRuc.text.trim(),
                        controllerPhone.text.trim(),
                        false,
                        widget.provider!.serverId,
                      ),
                    );
                  } else {
                    await context.read<ProviderProvider>().save(
                      Provider(
                        0,
                        controllerName.text.trim(),
                        controllerRuc.text.trim(),
                        controllerPhone.text.trim(),
                        false,
                        null,
                      ),
                    );
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: Text(isEditing ? 'Editar' : 'Crear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}