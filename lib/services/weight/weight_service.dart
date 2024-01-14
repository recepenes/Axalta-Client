import 'dart:convert';
import 'package:axalta/constants/api_url.dart';
import 'package:axalta/constants/user_token.dart';
import 'package:axalta/enums/menu_view.dart';
import 'package:axalta/model/weighing_detail_dto.dart';
import 'package:axalta/model/weighing_product_dto.dart';
import 'package:axalta/services/indicators/indicator_service.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as devtools show log;

class ApiService {
  Future<Map<String, dynamic>> postData(
      WeighingProductDto dto, MenuViews viewId) async {
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
        'indicatorId':
            (await IndicatorService().getIndicatorId(viewId)).toString(),
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
            'Kayıt alınırken bir hata oluştu: ${response.statusCode}';
        return result;
      }
    } catch (e) {
      result['errorMessage'] = 'Kayıt alınırken exception: ' + e.toString();
      return result;
    }
  }

  Future<Map<String, dynamic>> finishRecord(WeighingDetailDto dto) async {
    Map<String, dynamic> result = {
      'success': false,
      'errorMessage': '',
    };

    const path = "weighing/finish";
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
      devtools.log("Finish Record");
      final http.Response response = await http.post(
        uri,
        body: jsonEncode(data), // Verileri JSON formatına çevirin
        headers: {
          'Content-Type': 'application/json', // İçerik tipini belirtin
          'Authorization': 'Bearer $userToken'
        },
      );

      if (response.statusCode == 200) {
        result['success'] = true;
        return result;
      } else {
        result['errorMessage'] =
            'Finish Records alınırken bir hata oluştu: ${response.statusCode}';
        return result;
      }
    } catch (e) {
      result['errorMessage'] =
          'Finish Records alınırken exception: ' + e.toString();
      return result;
    }
  }

  Future<Map<String, dynamic>> deleteRecord(
      WeighingDetailDto dto, String productNumber) async {
    Map<String, dynamic> result = {
      'success': false,
      'errorMessage': '',
    };

    const path = "weighing/delete";
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
      "productNumber": productNumber,
    };

    try {
      devtools.log("Delte Record");
      final http.Response response = await http.post(
        uri,
        body: jsonEncode(data), // Verileri JSON formatına çevirin
        headers: {
          'Content-Type': 'application/json', // İçerik tipini belirtin
          'Authorization': 'Bearer $userToken'
        },
      );

      if (response.statusCode == 200) {
        result['success'] = true;
        return result;
      } else {
        result['errorMessage'] =
            'Delete Record alınırken bir hata oluştu: ${response.statusCode}';
        return result;
      }
    } catch (e) {
      result['errorMessage'] = 'Delete Record exception: ' + e.toString();
      return result;
    }
  }
}
