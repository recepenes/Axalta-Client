import 'package:axalta/exceptions/weighing_exceptions.dart';

class PackagedProductDto {
  int id;
  String productNumber;
  String weight;

  PackagedProductDto({
    required this.id,
    required this.productNumber,
    required this.weight,
  });

  factory PackagedProductDto.fromJson(Map<String, dynamic> json) {
    final packagedProduct = PackagedProductDto(
      id: json['id'] ?? 0,
      productNumber: json['productNumber'],
      weight: json['weight'],
    );
    if (packagedProduct.weight.isNotEmpty) {
      return packagedProduct;
    } else {
      throw PackagedProducNotFound();
    }
  }
}
