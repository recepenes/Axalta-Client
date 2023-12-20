import 'package:axalta/exceptions/weighing_exceptions.dart';

class WeighingDetailDto {
  String batchNo;
  int mixNo;
  int lineNumber;

  WeighingDetailDto({
    required this.batchNo,
    required this.mixNo,
    required this.lineNumber,
  });

  WeighingDetailDto.empty()
      : batchNo = "",
        mixNo = 0,
        lineNumber = 0;

  factory WeighingDetailDto.fromJson(Map<String, dynamic> json) {
    final detail = WeighingDetailDto(
      batchNo: json['batchNo'],
      mixNo: json['mixNo'],
      lineNumber: json['lineNumber'],
    );
    if (detail.batchNo.isNotEmpty) {
      return detail;
    } else {
      throw DetailsCouldNotFind();
    }
  }
}
