import 'package:axalta/exceptions/weighing_exceptions.dart';

class IndicatorDto {
  int id;
  int indicatorNo;
  String name;
  String iPAdress;
  int portNo;

  IndicatorDto({
    required this.id,
    required this.indicatorNo,
    required this.name,
    required this.iPAdress,
    required this.portNo,
  });

  IndicatorDto.empy()
      : id = 1,
        iPAdress = "",
        indicatorNo = 1,
        name = "",
        portNo = 1;

  factory IndicatorDto.fromJson(Map<String, dynamic> json) {
    final indicatorDto = IndicatorDto(
      id: json["id"],
      indicatorNo: json["indicatorNo"],
      name: json["name"],
      iPAdress: json["ipAdress"],
      portNo: json["portNo"],
    );

    if (indicatorDto.name.isNotEmpty) {
      return indicatorDto;
    } else {
      throw IndicatorNotFound();
    }
  }
}
