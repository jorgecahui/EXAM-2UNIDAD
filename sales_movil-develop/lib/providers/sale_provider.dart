import 'package:flutter/material.dart';
import 'package:sales/models/client.dart';
import 'package:sales/models/product.dart';
import 'package:sales/models/sale.dart';
import 'package:sales/services/sale_service.dart';

class SaleProvider extends ChangeNotifier {
  List<Sale> _sales = [];
  List<Client> _clients = [];
  List<Product> _products = [];
  bool _loading = false;

  final SaleService _service = SaleService();

  List<Sale> get sales => _sales;
  List<Client> get clients => _clients;
  List<Product> get products => _products;
  bool get loading => _loading;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();

    try {
      _sales = await _service.getAll();
    } catch (_) {
      _sales = [];
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> loadFormData() async {
    _loading = true;
    notifyListeners();

    try {
      _clients = await _service.getClients();
      _products = await _service.getProducts();
    } catch (_) {
      _clients = [];
      _products = [];
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> create(int clientId, int productId, int quantity) async {
    try {
      await _service.create(clientId, productId, quantity);
      await loadAll();
      return true;
    } catch (_) {
      return false;
    }
  }
}