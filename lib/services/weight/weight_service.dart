import 'dart:convert';
import 'package:axalta/constants/api_url.dart';
import 'package:axalta/constants/indicator.dart';
import 'package:axalta/constants/user_token.dart';
import 'package:axalta/model/weighing_product_dto.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as devtools show log;

class ApiService {
  Future<WeighingProductDto> postData(WeighingProductDto dto) async {

    WeighingProductDto weighingProduct = WeighingProductDto.empty();

    const path = "weighing";
    Uri uri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: apiRoute + path,
    );

    // POST isteği için gerekli veriler
    final Map<String, Object> data = {
      "lineNumber": dto.lineNumber,
      "batchNo": dto.batchNo,
      "mixNo": dto.mixNo,
      "isExtra": dto.isExtra,
      "productNumber": dto.productNumber,
      "isDone": dto.isDone
    };

    try {
      devtools.log("post");
      Uri modifiedUri = uri.replace(queryParameters: {
        'indicatorId': indicatorId.toString(),
      });
      final http.Response response = await http.post(
        modifiedUri,
        body: jsonEncode(data), // Verileri JSON formatına çevirin
        headers: {
          'Content-Type': 'application/json', // İçerik tipini belirtin
          'Authorization': 'Bearer $userToken'
        },
      );

      String jsonStr = response.body;

      Map<String, dynamic> jsonMap = json.decode(jsonStr);

      weighingProduct = WeighingProductDto.fromJson(jsonMap);

      if (response.statusCode == 200) {
        return weighingProduct;
      } else {
        devtools.log('Kayıt alınırken bir hata oluştu: ${response.statusCode}');
        devtools.log(response.body);
        return weighingProduct;
      }
    } catch (e) {
      devtools.log("Kayıt alınırken exception: " + e.toString());
    }
    return weighingProduct;
  }
}
