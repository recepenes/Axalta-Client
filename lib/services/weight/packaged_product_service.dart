import 'dart:convert';
import 'package:axalta/constants/api_url.dart';
import 'package:axalta/constants/user_token.dart';
import 'package:axalta/model/weighing_product_dto.dart';
import 'package:http/http.dart' as http;

class PackagedProductService {
  Future<Map<String, dynamic>> postData(WeighingProductDto dto) async {
    Map<String, dynamic> result = {
      'success': false,
      'weighingProduct': WeighingProductDto.empty(),
      'errorMessage': '',
    };

    const path = "weighing";
    Uri uri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: apiRoute + path,
    );

    final Map<String, Object> data = {
      "lineNumber": dto.lineNumber,
      "batchNo": dto.batchNo,
      "mixNo": dto.mixNo,
      "isExtra": dto.isExtra,
      "productNumber": dto.productNumber,
      "isDone": dto.isDone,
      "sequenceNumber": dto.sequenceNumber,
    };

    try {
      Uri modifiedUri = uri.replace(queryParameters: {
        'indicatorId': "999",
      });
      final http.Response response = await http.post(
        modifiedUri,
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken'
        },
      );

      String jsonStr = response.body;

      Map<String, dynamic> jsonMap = json.decode(jsonStr);

      WeighingProductDto weighingProduct = WeighingProductDto.fromJson(jsonMap);

      if (response.statusCode == 200) {
        result['success'] = true;
        result['weighingProduct'] = weighingProduct;
        return result;
      } else {
        result['errorMessage'] =
            'Paketli kayıt alınırken bir hata oluştu: ${response.statusCode}';
        return result;
      }
    } catch (e) {
      result['errorMessage'] =
          'Paketli kayıt alınırken exception: ' + e.toString();
      return result;
    }
  }
}
