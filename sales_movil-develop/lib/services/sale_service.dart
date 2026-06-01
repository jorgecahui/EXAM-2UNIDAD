import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:sales/config/app_config.dart';
import 'package:sales/models/client.dart';
import 'package:sales/models/product.dart';
import 'package:sales/models/sale.dart';

class SaleService {
  final String apiUrl = AppConfig.apiUrl;

  Future<List<Client>> getClients() async {
    var url = Uri.http(apiUrl, '/client/clients/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = convert.jsonDecode(response.body);
      return data.map((json) => Client(
        0,
        json['name'].toString(),
        json['document_number'].toString(),
        true,
        json['id'],
      )).toList();
    }
    throw Exception('Error al obtener clientes');
  }

  Future<List<Product>> getProducts() async {
    var url = Uri.http(apiUrl, '/product/products/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = convert.jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Error al obtener productos');
  }

  Future<Sale> create(int clientId, int productId, int quantity) async {
    var url = Uri.http(apiUrl, '/sale/sales/');
    var body = convert.jsonEncode({
      'client': clientId,
      'details': [
        {'product': productId, 'quantity': quantity},
      ],
    });

    var response = await http.post(
      url,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return Sale.fromJson(convert.jsonDecode(response.body));
    }
    throw Exception('Error al crear venta: ${response.statusCode}');
  }

  Future<List<Sale>> getAll() async {
    var url = Uri.http(apiUrl, '/sale/sales/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = convert.jsonDecode(response.body);
      return data.map((json) => Sale.fromJson(json)).toList();
    }
    throw Exception('Error al obtener ventas');
  }
}