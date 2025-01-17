import 'dart:async';

import 'package:axalta/constants/api_url.dart';
import 'package:axalta/enums/menu_view.dart';
import 'package:axalta/model/weighing_detail_dto.dart';
import 'package:axalta/model/weighing_product_dto.dart';
import 'package:axalta/services/auth_service.dart';
import 'package:axalta/services/indicators/indicator_service.dart';
import 'package:axalta/services/weight/detail_service.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'dart:developer' as devtools show log;

import 'package:fp_bt_printer/fp_bt_printer.dart';

class BlueToothService {
  static List<PrinterDevice> devices = [];
  static PrinterDevice? device;
  static bool connected = false;
  static List<WeighingDetailDto> tempDto =
      List<WeighingDetailDto>.empty(growable: true);

  static FpBtPrinter printer = FpBtPrinter();

  static Future connectAndPrint(WeighingDetailDto dto, MenuViews viewId) async {
    List<WeighingProductDto> reports =
        (await DetailService().getDetails(dto))["details"];
    resultMap[dto] = reports;

    await setConnet(devices[0]);
    if (getStatus()) {
      await printTicket(dto, viewId);
    }
  }

  static Future connectAndPrintCumulative(WeighingDetailDto dto) async {
    await setConnet(devices[0]);
    if (getStatus()) {
      await printTicketCumulative(dto);
    }
  }

  static Future connectAndPrintList(MenuViews viewId) async {
    for (WeighingDetailDto x in tempDto) {
      List<WeighingProductDto> reports =
          (await DetailService().getDetails(x))["details"];
      resultMap[x] = reports;
    }

    await setConnet(devices[0]);
    if (getStatus()) {
      for (WeighingDetailDto x in tempDto) {
        await printTicket(x, viewId);
      }
      tempDto.clear();
    }
  }

  static Future setDto(WeighingDetailDto dto, MenuViews viewId) async =>
      await connectAndPrint(dto, viewId);

  static void setListDto(WeighingDetailDto dto) => tempDto.add(dto);

  static Future<void> autoBtConnect() async {
    await getDevices();
    await setConnet(devices[0]);
  }

  static FpBtPrinter getPrinter() {
    return printer;
  }

  static bool getStatus() {
    return connected;
  }

  static PrinterDevice? getDevice() {
    return device;
  }

  static Future<List<PrinterDevice>> getDevices() async {
    final response = await printer.scanBondedDevices();

    devices = response;

    return devices;
  }

  static Future<void> setConnet(PrinterDevice d) async {
    if (devices[0].name == "SPP-R310") {
      final response = await printer.checkConnection(d.address);
      if (response.success) {
        device = d;
        connected = true;
      } else {
        connected = false;
      }
    }
  }

  static void clearLastRecord() {
    resultMap.clear();
  }

  static List<WeighingProductDto> lastRecord = [];

  static Map<WeighingDetailDto, List<WeighingProductDto>> resultMap = {};

  static Future<void> printTicket(
      WeighingDetailDto dto, MenuViews viewId) async {
    try {
      String address = device!.address;

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      List<WeighingProductDto> reports =
          (await DetailService().getDetails(dto))["details"];

      // resultMap[dto] = reports;

      if (reports.isEmpty) {
        devtools.log("Rapor detayı bulunamadı");
        return;
      }

      var lineNumber = reports[0].lineNumber;
      var batchNo = reports[0].batchNo;
      var mixNo = reports[0].mixNo;

      bytes += generator.text("Tarih Saat:" + DateTime.now().toString(),
          styles: const PosStyles(align: PosAlign.left));

      var operatorName = "";
      var result = await AuthService().getUserName();
      if (result['success']) {
        operatorName = result['user'];
      }
      bytes += generator.text(
          "Operator: ${convertTurkishToEnglish(operatorName)}",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text(
          "Tarti: ${convertTurkishToEnglish(await IndicatorService().getIndicatorNameById(reports[0].indicatorId, viewId))}",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text('Hat No: $lineNumber',
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text("Batch No: ${convertTurkishToEnglish(batchNo)}",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text("Mix No: $mixNo",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.feed(1);

      // bytes += generator.imageRaster(thumbnail, align: PosAlign.center);

      bytes += generator.text('Sira   Ürün No                   Miktar(kg)',
          styles: const PosStyles(align: PosAlign.left));
      for (var x in reports) {
        bytes += generator.text(
            '${x.sequenceNumber}${addWhiteSpaceBySequence(x.sequenceNumber.toString())}${convertTurkishToEnglish(x.productNumber)}${addWhiteSpace(x.productNumber.toString())}${x.weight}',
            styles: const PosStyles(align: PosAlign.left));
      }

      bytes += generator.reset();
      // bytes += generator.setGlobalCodeTable('CP1252');
      bytes += generator.feed(1);

      bytes += generator.qrcode(
          '${reportRoute}lineNumber=$lineNumber&batchNo=$batchNo&mixNo=$mixNo',
          size: QRSize.Size4);
      bytes += generator.feed(2);

      final resp = await printer.printData(bytes, address: address);
      if (!resp.success) {
        connected = false;
      } else {}
      devtools.log("bt info: " + resp.message);
    } catch (e) {
      connected = false;
      devtools.log("Yazdırılamadı");
    }
  }

  static Future<void> printTicketCumulative(WeighingDetailDto dto) async {
    try {
      String address = device!.address;

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      List<WeighingProductDto> reports =
          (await DetailService().getDetailsCumulative(dto))["details"];

      if (reports.isEmpty) {
        devtools.log("Rapor detayı bulunamadı");
        return;
      }

      var lineNumber = reports[0].lineNumber;
      var batchNo = reports[0].batchNo;
      var mixNo = reports[0].mixNo;

      bytes += generator.text("Tarih Saat:" + DateTime.now().toString(),
          styles: const PosStyles(align: PosAlign.left));

      var operatorName = "";
      var result = await AuthService().getUserName();
      if (result['success']) {
        operatorName = result['user'];
      }
      bytes += generator.text(
          "Operator: ${convertTurkishToEnglish(operatorName)}",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text(
          "Tarti: ${convertTurkishToEnglish(await IndicatorService().getIndicatorNameById(reports[0].indicatorId, MenuViews.cumulative))}",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text('Hat No: $lineNumber',
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text("Batch No: ${convertTurkishToEnglish(batchNo)}",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text("Mix No: $mixNo",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.feed(1);

      // bytes += generator.imageRaster(thumbnail, align: PosAlign.center);

      bytes += generator.text('Sira   Ürün No               Miktar(kg)',
          styles: const PosStyles(align: PosAlign.left));
      for (var x in reports) {
        bytes += generator.text(
            '${x.sequenceNumber}${addWhiteSpaceBySequence(x.sequenceNumber.toString())}${convertTurkishToEnglish(x.productNumber)}${addWhiteSpace(x.productNumber.toString())}${x.weight}',
            styles: const PosStyles(align: PosAlign.left));
      }

      bytes += generator.reset();
      // bytes += generator.setGlobalCodeTable('CP1252');
      bytes += generator.feed(1);

      bytes += generator.qrcode(
          '${reportRoute}lineNumber=$lineNumber&batchNo=$batchNo&mixNo=$mixNo',
          size: QRSize.Size4);
      bytes += generator.feed(2);

      final resp = await printer.printData(bytes, address: address);
      if (!resp.success) {
        connected = false;
      } else {}
      devtools.log("bt info: " + resp.message);
    } catch (e) {
      connected = false;
      devtools.log("Yazdırılamadı");
    }
  }

  static Future lastPrintTicket(MenuViews viewId) async {
    await setConnet(devices[0]);
    if (getStatus()) {
      //for (WeighingProductDto x in lastRecord) {

      for (var key in resultMap.keys) {
        var value = resultMap[key];
        await printLastTicket(value!, viewId);
      }
      resultMap.clear();

      //}
    }
  }

  static Future<void> printLastTicket(
      List<WeighingProductDto> dto, MenuViews viewId) async {
    try {
      String address = device!.address;

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      List<WeighingProductDto> reports = dto;

      if (reports.isEmpty) {
        devtools.log("Rapor detayı bulunamadı");
        return;
      }

      var lineNumber = reports[0].lineNumber;
      var batchNo = reports[0].batchNo;
      var mixNo = reports[0].mixNo;

      bytes += generator.text("Tarih Saat:" + DateTime.now().toString(),
          styles: const PosStyles(align: PosAlign.left));

      var operatorName = "";
      var result = await AuthService().getUserName();
      if (result['success']) {
        operatorName = result['user'];
      }
      bytes += generator.text(
          "Operator: ${convertTurkishToEnglish(operatorName)}",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text(
          "Tarti: ${convertTurkishToEnglish(await IndicatorService().getIndicatorNameById(reports[0].indicatorId, viewId))}",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text('Hat No: $lineNumber',
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text("Batch No: ${convertTurkishToEnglish(batchNo)}",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text("Mix No: $mixNo",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.feed(1);

      // bytes += generator.imageRaster(thumbnail, align: PosAlign.center);

      bytes += generator.text('Sira   Ürün No                   Miktar(kg)',
          styles: const PosStyles(align: PosAlign.left));
      for (var x in reports) {
        bytes += generator.text(
            '${x.sequenceNumber}${addWhiteSpaceBySequence(x.sequenceNumber.toString())}${convertTurkishToEnglish(x.productNumber)}${addWhiteSpace(x.productNumber.toString())}${x.weight}',
            styles: const PosStyles(align: PosAlign.left));
      }

      bytes += generator.reset();
      // bytes += generator.setGlobalCodeTable('CP1252');
      bytes += generator.feed(1);

      bytes += generator.qrcode(
          '${reportRoute}lineNumber=$lineNumber&batchNo=$batchNo&mixNo=$mixNo',
          size: QRSize.Size4);
      bytes += generator.feed(2);

      final resp = await printer.printData(bytes, address: address);
      if (!resp.success) {
        connected = false;
      } else {}
      devtools.log("bt info: " + resp.message);
    } catch (e) {
      connected = false;
      devtools.log("Yazdırılamadı");
    }
  }

  static String addWhiteSpace(String str) {
    String whiteSpace = "";
    for (int i = 0; i < 26 - str.length; i++) {
      whiteSpace += " ";
    }

    return whiteSpace;
  }

  static String addWhiteSpaceBySequence(String str) {
    String whiteSpace = "";
    for (int i = 0; i < 7 - str.length; i++) {
      whiteSpace += " ";
    }

    return whiteSpace;
  }

  static String convertTurkishToEnglish(String input) {
    final Map<String, String> turkishToEnglishMap = {
      'İ': 'I',
      'ı': 'i',
      'Ç': 'C',
      'ç': 'c',
      'Ş': 'S',
      'ş': 's',
      'Ğ': 'G',
      'ğ': 'g',
      'Ü': 'U',
      'ü': 'u',
      'Ö': 'O',
      'ö': 'o',
    };

    return input.replaceAllMapped(
      RegExp('[İıÇçŞşĞğÜüÖö]'),
      (match) => turkishToEnglishMap[match.group(0)]!,
    );
  }
}
