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

  FpBtPrinter printer = FpBtPrinter();

  Future<void> autoBtConnect() async {
    await getDevices();
    await setConnet(devices[0]);
  }

  FpBtPrinter getPrinter() {
    return printer;
  }

  bool getStatus() {
    return connected;
  }

  PrinterDevice? getDevice() {
    return device;
  }

  Future<List<PrinterDevice>> getDevices() async {
    final response = await printer.scanBondedDevices();

    devices = response;

    return devices;
    //if (devices[0].name == "SPP-R310") {
    //setConnet(devices[0]);
    //}
  }

  Future<void> setConnet(PrinterDevice d) async {
    if (devices[0].name == "SPP-R310") {
      final response = await printer.checkConnection(d.address);

      if (response.success) {
        device = d;
        connected = true;
      } else {
        connected = false;
        device = null;
      }
    }
  }

  Future<void> printTicket(WeighingDetailDto dto) async {
    try {
      String address = device!.address;
      //TODO:catch status değişecek
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
      bytes += generator.text("Operator: Enes",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text("Tarti: $indicatorName",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text('Hat No: $lineNumber',
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text("Batch No: $batchNo",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text("Mix No: $mixNo",
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.feed(1);

      // bytes += generator.imageRaster(thumbnail, align: PosAlign.center);

      bytes += generator.text('Sira   Ürün No                   Miktar',
          styles: const PosStyles(align: PosAlign.left));
      for (var x in reports) {
        bytes += generator.text(
            '${x.sequenceNumber}${addWhiteSpaceBySequence(x.sequenceNumber.toString())}${x.productNumber}${addWhiteSpace(x.productNumber.toString())}${x.weight}',
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
      }
      devtools.log(resp.message);
    } catch (e) {
      connected = false;
      devtools.log("Yazdırılamadı");
    }
  }

  String addWhiteSpace(String str) {
    String whiteSpace = "";
    for (int i = 0; i < 26 - str.length; i++) {
      whiteSpace += " ";
    }

    return whiteSpace;
  }

  String addWhiteSpaceBySequence(String str) {
    String whiteSpace = "";
    for (int i = 0; i < 7 - str.length; i++) {
      whiteSpace += " ";
    }

    return whiteSpace;
  }
}
