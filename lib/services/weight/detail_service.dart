import 'dart:convert';

import 'package:axalta/constants/api_url.dart';
import 'package:axalta/constants/user_token.dart';
import 'package:axalta/model/weighing_detail_dto.dart';
import 'package:axalta/model/weighing_product_dto.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as devtools show log;

class DetailService {
  Future<Map<String, dynamic>> getDetails(WeighingDetailDto dto) async {
    Map<String, dynamic> result = {
      'success': false,
      'details': List<WeighingProductDto>.empty(),
      'errorMessage': '',
    };

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
      var details = jsonList
          .map((dynamic e) =>
              WeighingProductDto.fromJson(e as Map<String, dynamic>))
          .toList();

      if (response.statusCode == 200) {
        result['success'] = true;
        result['details'] = details;
        return result;
      } else {
        devtools
            .log('Detaylar alınırken bir hata oluştu: ${response.statusCode}');
        result['errorMessage'] =
            'Detaylar alınırken bir hata oluştu: ${response.statusCode}';
        result['details'] = details;
        return result;
      }
    } catch (e) {
      devtools.log("Detaylar alınırken exception: " + e.toString());
      result['errorMessage'] = 'Detaylar alınırken excepiton: ' + e.toString();
      return result;
    }
  }

  Future<Map<String, dynamic>> getDetailsBetweenMix(
      WeighingDetailDto dto, int mixNoFish) async {
    Map<String, dynamic> result = {
      'success': false,
      'details': List<WeighingProductDto>.empty(),
      'errorMessage': '',
    };

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
      var details = jsonList
          .map((dynamic e) =>
              WeighingProductDto.fromJson(e as Map<String, dynamic>))
          .toList();

      if (response.statusCode == 200) {
        result['success'] = true;
        result['details'] = details;
        return result;
      } else {
        devtools.log(
            'Detaylar aralık ile alınırken bir hata oluştu: ${response.statusCode}');
        result['errorMessage'] =
            'Detaylar aralık ile  alınırken bir hata oluştu: ${response.statusCode}';
        result['details'] = details;
        return result;
      }
    } catch (e) {
      devtools.log("Detaylar aralık ile alınırken exception: " + e.toString());
      result['errorMessage'] =
          'Detaylar aralık ile alınırken excepiton: ' + e.toString();
      return result;
    }
  }
}
