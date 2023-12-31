import 'dart:convert';

import 'package:axalta/constants/api_url.dart';
import 'package:axalta/constants/user_token.dart';
import 'package:axalta/model/weighing_detail_dto.dart';
import 'package:axalta/model/weighing_product_dto.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as devtools show log;

class DetailService {
  Future<List<WeighingProductDto>> getDetails(WeighingDetailDto dto) async {
    List<WeighingProductDto> details = List.empty();

    const path = "weighing/detail";
    Uri uri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: apiRoute + path,
    );

    final Map<String, Object> data = {
      "batchNo": dto.batchNo,
      "mixNo": dto.mixNo,
      "lineNumber": dto.lineNumber,
    };

    try {
      devtools.log("Details Get");
      final http.Response response = await http.post(
        uri,
        body: jsonEncode(data), // Verileri JSON formatına çevirin
        headers: {
          'Content-Type': 'application/json', // İçerik tipini belirtin
          'Authorization': 'Bearer $userToken'
        },
      );

      String jsonStr = response.body;

      List<dynamic> jsonList = jsonDecode(jsonStr);
      details = jsonList
          .map((dynamic e) =>
              WeighingProductDto.fromJson(e as Map<String, dynamic>))
          .toList();

      if (response.statusCode == 200) {
        return details;
      } else {
        devtools
            .log('Detaylar alınırken bir hata oluştu: ${response.statusCode}');
        devtools.log(response.body);
        return details;
      }
    } catch (e) {
      devtools.log("Detaylar alınırken bir hata oluştu: " + e.toString());
    }

    return details;
  }

  Future<List<WeighingProductDto>> getDetailsBetweenMix(
      WeighingDetailDto dto, int mixNoFish) async {
    List<WeighingProductDto> details = List.empty();

    const path = "weighing/detail/middle";
    Uri uri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: apiRoute + path,
    );

    final Map<String, Object> data = {
      "batchNo": dto.batchNo,
      "mixNo": dto.mixNo,
      "lineNumber": dto.lineNumber,
      "mixNoFinish": mixNoFish
    };

    try {
      devtools.log("Details Get");
      final http.Response response = await http.post(
        uri,
        body: jsonEncode(data), // Verileri JSON formatına çevirin
        headers: {
          'Content-Type': 'application/json', // İçerik tipini belirtin
          'Authorization': 'Bearer $userToken'
        },
      );

      String jsonStr = response.body;

      List<dynamic> jsonList = jsonDecode(jsonStr);
      details = jsonList
          .map((dynamic e) =>
              WeighingProductDto.fromJson(e as Map<String, dynamic>))
          .toList();

      if (response.statusCode == 200) {
        return details;
      } else {
        devtools
            .log('Detaylar alınırken bir hata oluştu: ${response.statusCode}');
        devtools.log(response.body);
        return details;
      }
    } catch (e) {
      devtools.log("Detaylar alınırken bir hata oluştu: " + e.toString());
    }

    return details;
  }
}
