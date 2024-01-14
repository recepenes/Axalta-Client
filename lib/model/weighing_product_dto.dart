// ignore_for_file: prefer_const_constructors

import 'package:axalta/exceptions/weighing_exceptions.dart';
import 'package:flutter/material.dart';

class WeighingProductDto {
  int id;
  int lineNumber;
  String batchNo;
  int mixNo;
  bool isExtra;
  int sequenceNumber;
  String productNumber;
  String weight;
  bool isDone;
  int indicatorId;

  WeighingProductDto({
    required this.id,
    required this.lineNumber,
    required this.batchNo,
    required this.mixNo,
    required this.isExtra,
    required this.sequenceNumber,
    required this.productNumber,
    required this.weight,
    required this.isDone,
    required this.indicatorId,
  });

  WeighingProductDto.empty()
      : id = 0,
        lineNumber = 0,
        batchNo = "",
        mixNo = 0,
        isExtra = false,
        sequenceNumber = 0,
        productNumber = "Bekleniyor",
        weight = "Bekleniyor",
        isDone = false,
        indicatorId = 1;

  DataRow getRows() {
    return DataRow(cells: [
      DataCell(Text(sequenceNumber.toString(), style: TextStyle(fontSize: 10))),
      DataCell(Text(mixNo.toString(), style: TextStyle(fontSize: 10))),
      DataCell(Text(productNumber, style: TextStyle(fontSize: 10))),
      DataCell(Text(weight, style: TextStyle(fontSize: 10))),
    ]);
  }

  factory WeighingProductDto.fromJson(Map<String, dynamic> json) {
    final weighingProduct = WeighingProductDto(
        id: json['id'] ?? 0,
        lineNumber: json['lineNumber'],
        batchNo: json['batchNo'],
        mixNo: json['mixNo'],
        isExtra: json['isExtra'],
        sequenceNumber: json['sequenceNumber'],
        productNumber: json['productNumber'],
        weight: json['weight'],
        isDone: json['isDone'],
        indicatorId: json["indicatorId"]);
    if (weighingProduct.weight.isNotEmpty) {
      return weighingProduct;
    } else {
      throw WeighingNotRecorded();
    }
  }
}
