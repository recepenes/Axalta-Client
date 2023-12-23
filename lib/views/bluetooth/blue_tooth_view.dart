import 'package:flutter/material.dart';
import 'package:fp_bt_printer/fp_bt_printer.dart';

import '../../services/blue_tooth/blue_tooth_service.dart';

class BlueToothView extends StatefulWidget {
  const BlueToothView({Key? key}) : super(key: key);

  @override
  State<BlueToothView> createState() => _BlueToothViewState();
}

class _BlueToothViewState extends State<BlueToothView> {
  FpBtPrinter printer = BlueToothService().getPrinter();
  List<PrinterDevice> devices = List<PrinterDevice>.empty(growable: true);
  // ignore: unused_field
  static PrinterDevice? device;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List of devices - Printers'),
      ),
      body: Column(
        children: [
          Container(
            child: Column(
              children: [
                TextButton(
                  child: const Center(child: Text("Open Settings")),
                  onPressed: () => printer.openSettings(),
                )
              ],
            ),
          ),
          const Divider(),
          const Text("Search Paired Bluetooth"),
          TextButton(
            onPressed: () async {
              devices = await BlueToothService().getDevices();
              setState(() {
                devices = devices;
              });
            },
            child: const Text("Search"),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Card(
              child: Container(
                padding: const EdgeInsets.all(5),
                height: 100,
                child: ListView.separated(
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: devices.length > 0 ? devices.length : 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.print_rounded),
                      onTap: () async {
                        await BlueToothService().setConnet(devices[index]);

                        setState(() {
                          device = BlueToothService().getDevice();
                        });
                      },
                      title: Text(
                          '${devices[index].name} - ${devices[index].address}'),
                      subtitle: const Text("Click to connect"),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              color: Colors.grey.shade300,
              child: Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.print_rounded,
                        color: BlueToothService().getStatus()
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                  ListTile(
                    minVerticalPadding: 5,
                    dense: true,
                    title: BlueToothService().getStatus()
                        ? Center(
                            child: Text(BlueToothService().getDevice()!.name!))
                        : const Center(child: Text("No device")),
                    subtitle: BlueToothService().getStatus()
                        ? Center(
                            child:
                                Text(BlueToothService().getDevice()!.address))
                        : const Center(
                            child: Text("Select a device of the list")),
                  ),
                  TextButton(
                    onPressed: BlueToothService().getStatus()
                        ? () => BlueToothService().printTicket()
                        : null,
                    child: const Text("PRINT DATA"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
