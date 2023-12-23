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

  Future<void> printTicket() async {
    String address = device!.address;
    //TODO:catch status değişecek
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // //  Print image:
    //final ByteData data = await rootBundle.load('assets/wz.png');
    //final Uint8List bytesImg = data.buffer.asUint8List();
    //var image = decodePng(bytesImg);

    // resize
    //var thumbnail =
    //  copyResize(image!, interpolation: Interpolation.nearest, height: 200);

    bytes += generator.text("fp_bt_printer",
        styles: PosStyles(align: PosAlign.center, bold: true));

    // bytes += generator.imageRaster(thumbnail, align: PosAlign.center);

    bytes += generator.reset();
    bytes += generator.setGlobalCodeTable('CP1252');
    bytes += generator.feed(1);
    bytes += generator.text("HELLO PRINTER by FPV",
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.qrcode("https://github.com/FranciscoPV94",
        size: QRSize.Size6);
    bytes += generator.feed(1);
    bytes += generator.feed(1);

    try {
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
}
