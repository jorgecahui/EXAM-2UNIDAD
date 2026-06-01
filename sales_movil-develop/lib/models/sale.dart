class Sale {
  final int id;
  final String createdAt;
  final double subtotal;
  final double igv;
  final double total;
  final int clientId;
  final String clientName;
  final int productId;
  final String productName;

  Sale({
    required this.id,
    required this.createdAt,
    required this.subtotal,
    required this.igv,
    required this.total,
    required this.clientId,
    required this.clientName,
    required this.productId,
    required this.productName,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      createdAt: json['created_at'] ?? '',
      subtotal: double.parse(json['subtotal'].toString()),
      igv: double.parse(json['igv'].toString()),
      total: double.parse(json['total'].toString()),
      clientId: json['client']['id'],
      clientName: json['client']['name'].toString(),
      productId: json['details'][0]['product']['id'],
      productName: json['details'][0]['product']['name'].toString(),
    );
  }
}