import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:axalta/constants/api_url.dart';
import 'package:axalta/constants/indicator.dart';
import 'package:axalta/constants/user_token.dart';
import 'package:axalta/enums/menu_view.dart';
import 'package:axalta/model/indicator_dto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class IndicatorService {
  static List<IndicatorDto> indicators = List.empty();

  Future<Map<String, dynamic>> getAllIndicators() async {
    Map<String, dynamic> result = {
      'success': false,
      'indicators': List<IndicatorDto>.empty(),
      'errorMessage': '',
    };

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
        result['success'] = true;
        result['indicators'] = indicators;
        return result;
      } else {
        result['errorMessage'] =
            'Indicators alınırken bir hata oluştu: ${response.statusCode}';
        return result;
      }
    } catch (e) {
      result['errorMessage'] =
          'Indicators alınırken exception : ' + e.toString();
      return result;
    }
  }

  Future<Map<String, dynamic>> sendTareToIndicator(MenuViews viewId) async {
    Map<String, dynamic> result = {
      'success': false,
      'errorMessage': '',
    };

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
        'indicatorId': await getIndicatorId(viewId),
      });
      final http.Response response = await http.get(
        modifiedUri,
        headers: {
          'Content-Type': 'application/json', // İçerik tipini belirtin
          'Authorization': 'Bearer $userToken'
        },
      );
      if (response.statusCode == 200) {
        result['success'] = true;
      } else {
        result['errorMessage'] =
            'Tare alınırken bir hata oluştu: ${response.statusCode}';
      }
    } catch (e) {
      result['errorMessage'] = 'Tare alınırken exception: ' + e.toString();
    }

    return result;
  }

  Future<Map<String, dynamic>> sendClearToIndicator(MenuViews viewId) async {
    Map<String, dynamic> result = {
      'success': false,
      'errorMessage': '',
    };

    try {
      const path = "indicator/setclear";
      Uri uri = Uri(
        scheme: scheme,
        host: host,
        port: port,
        path: apiRoute + path,
      );
      devtools.log("Send Clear to Indicator");

      Uri modifiedUri = uri.replace(queryParameters: {
        'indicatorId': await getIndicatorId(viewId),
      });
      final http.Response response = await http.get(
        modifiedUri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken'
        },
      );
      if (response.statusCode == 200) {
        result['success'] = true;
      } else {
        result['errorMessage'] =
            'Clear alınırken bir hata oluştu: ${response.statusCode}';
      }
    } catch (e) {
      result['errorMessage'] = 'Clear alınırken exception: ' + e.toString();
    }

    return result;
  }

  Future<void> saveSelections(String key, List<String> selections) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, selections);
  }

  Future<void> loadSavedSelections(
      String key, Function(List<String>) callback) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    callback(prefs.getStringList(key) ?? []);
  }

  Future<String> getIndicatorId(MenuViews viewId) async {
    String indicatorId = "";
    switch (viewId) {
      case MenuViews.pigment:
        await loadSavedSelections(pigmentIndicatorLocal, (values) {
          indicatorId = values[0];
        });
        break;
      case MenuViews.middleView1:
        await loadSavedSelections(middle1IndicatorLocal, (values) {
          indicatorId = values[0];
        });
        break;
      case MenuViews.middleView2:
        await loadSavedSelections(middle2IndicatorLocal, (values) {
          indicatorId = values[0];
        });
        break;
      default:
        break;
    }
    return indicatorId;
  }

  Future<String> getIndicatorNameById(int indicatorId, MenuViews viewId) async {
    var result = await IndicatorService().getAllIndicators();
    String indicatorName = "";
    if (result['success']) {
      indicators = result['indicators'];
    }

    switch (viewId) {
      case MenuViews.pigment:
      case MenuViews.middleView1:
      case MenuViews.middleView2:
        indicatorName = indicators.firstWhere((x) => x.id == indicatorId).name;
        break;
      case MenuViews.cumulative:
        indicatorName = "Kümülatif Çıktı";
        break;
      case MenuViews.kaba:
        indicatorName = "Kaba Tartım";
        break;
    }

    return indicatorName;
  }
}
