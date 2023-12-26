import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:axalta/constants/api_url.dart';
import 'package:axalta/constants/indicator.dart';
import 'package:axalta/constants/user_token.dart';
import 'package:axalta/model/indicator_dto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class IndicatorService {
  static List<IndicatorDto> indicators = List.empty();

  Future<List<IndicatorDto>> getAllIndicators() async {
    const path = "indicator";
    Uri uri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: apiRoute + path,
    );
    try {
      devtools.log("Get All Indicators");
      final http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json', // İçerik tipini belirtin
          'Authorization': 'Bearer $userToken'
        },
      );

      String jsonStr = response.body;

      List<dynamic> jsonList = jsonDecode(jsonStr);

      indicators = jsonList
          .map((dynamic e) => IndicatorDto.fromJson(e as Map<String, dynamic>))
          .toList();

      if (response.statusCode == 200) {
        return indicators;
      } else {
        devtools.log(
            'Indicators alınırken bir hata oluştu: ${response.statusCode}');
        devtools.log(response.body);
        return indicators;
      }
    } catch (e) {
      devtools.log("Indicators alınırken exception : " + e.toString());
    }

    return indicators;
  }

  Future sendTareToIndicator() async {
    try {
      const path = "indicator/settare";
      Uri uri = Uri(
        scheme: scheme,
        host: host,
        port: port,
        path: apiRoute + path,
      );
      devtools.log("Send Tare to Indicator");

      Uri modifiedUri = uri.replace(queryParameters: {
        'indicatorId': indicatorId.toString(),
      });
      final http.Response response = await http.get(
        modifiedUri,
        headers: {
          'Content-Type': 'application/json', // İçerik tipini belirtin
          'Authorization': 'Bearer $userToken'
        },
      );
      if (response.statusCode != 200) {
        devtools.log('Tare alınırken bir hata oluştu: ${response.statusCode}');
        devtools.log(response.body);
      }
    } catch (e) {
      devtools.log("Tare alınırken exception: " + e.toString());
    }
  }

  Future<IndicatorDto> getSavedIndicator() async {
    var locals = await loadIndicatorIdFromDevice();
    int localIndicatorId = locals['indicatorId'];
    return indicators.firstWhere((x) => x.id == localIndicatorId);
  }

  Future<void> saveIndicatorIdToDevice(
      int indicatorId, String indicatorName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('indicatorId', indicatorId);
    await prefs.setString('indicatorName', indicatorName);
  }

  Future<Map<String, dynamic>> loadIndicatorIdFromDevice() async {
    Map<String, dynamic> localIndicator = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int indicatorId = prefs.getInt('indicatorId') ?? 1;
    String? indicatorName = prefs.getString('indicatorName');
    localIndicator.addAll({
      'indicatorId': indicatorId,
      'indicatorName': indicatorName,
    });

    return localIndicator;
  }
}
