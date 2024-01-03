import 'dart:async';

import 'package:axalta/constants/api_url.dart';
import 'package:axalta/constants/indicator.dart';
import 'package:axalta/model/weighing_detail_dto.dart';
import 'package:axalta/model/weighing_product_dto.dart';
import 'package:axalta/services/weight/detail_service.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'dart:developer' as devtools show log;

import 'package:fp_bt_printer/fp_bt_printer.dart';

class BlueToothService {
  static List<PrinterDevice> devices = [];
  static PrinterDevice? device;
  static bool connected = false;
  static Timer? _timer;
  static List<WeighingDetailDto> tempDto =
      List<WeighingDetailDto>.empty(growable: true);

  static FpBtPrinter printer = FpBtPrinter();

  static Future startTimer() async {
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      await connectAndPrint();
    });
  }

  static void _stopTimer() {
    _timer?.cancel();
  }

  static Future connectAndPrint() async {
    await setConnet(devices[0]);
    if (getStatus()) {
      _stopTimer();

      for (WeighingDetailDto x in tempDto) {
        await printTicket(x);
      }
      tempDto.clear();
    }
  }

  static void setDto(WeighingDetailDto dto) => tempDto.add(dto);

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

  static Future<void> printTicket(WeighingDetailDto dto) async {
    try {
      String address = device!.address;

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      List<WeighingProductDto> reports = await DetailService().getDetails(dto);

      if (reports.isEmpty) {
        devtools.log("Rapor detayı bulunamadı");
        return;
      }

      var lineNumber = reports[0].lineNumber;
      var batchNo = reports[0].batchNo;
      var mixNo = reports[0].mixNo;

      bytes += generator.text("Tarih Saat:" + DateTime.now().toString(),
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text("Operator: ${convertTurkishToEnglish("Enes")}",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text(
          "Tarti: ${convertTurkishToEnglish(indicatorName)}",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text('Hat No: $lineNumber',
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text("Batch No: ${convertTurkishToEnglish(batchNo)}",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text("Mix No: $mixNo",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.feed(1);

      // bytes += generator.imageRaster(thumbnail, align: PosAlign.center);

      bytes += generator.text('Sira   Ürün No                   Miktar',
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
      } else {
      }
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
