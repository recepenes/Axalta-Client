import 'package:axalta/constants/indicator.dart';
import 'package:axalta/model/indicator_dto.dart';
import 'package:axalta/services/indicators/indicator_service.dart';
import 'package:axalta/views/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class IndicatorView extends StatefulWidget {
  const IndicatorView({super.key});
  @override
  _IndicatorViewState createState() => _IndicatorViewState();
}

class _IndicatorViewState extends State<IndicatorView> {
  List<IndicatorDto> devices = List<IndicatorDto>.empty(growable: true);
  IndicatorDto localIndicator = IndicatorDto.empy();

  @override
  void initState() {
    super.initState();
    getAllIndicators();
    IndicatorService().loadSavedSelections(pigmentIndicatorLocal, (values) {
      setState(() {
        selectedItems1 = values;
      });
    });
    IndicatorService().loadSavedSelections(middle1IndicatorLocal, (values) {
      setState(() {
        selectedItems2 = values;
      });
    });
    IndicatorService().loadSavedSelections(middle2IndicatorLocal, (values) {
      setState(() {
        selectedItems3 = values;
      });
    });
  }

  List<String> selectedItems1 = [];
  List<String> selectedItems2 = [];
  List<String> selectedItems3 = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terazi Ayarları"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MultiSelectDialogField(
              items: devices
                  .map((item) =>
                      MultiSelectItem<String>(item.id.toString(), item.name))
                  .toList(),
              title: const Text("Pigment Tartım"),
              selectedColor: Colors.blue,
              buttonText: const Text("Pigment Tartım"),
              onConfirm: (values) {
                setState(() {
                  selectedItems1 = values;
                  IndicatorService()
                      .saveSelections(pigmentIndicatorLocal, selectedItems1);
                });
              },
              initialValue: selectedItems1, // Güncellendi
            ),
            const SizedBox(height: 20),
            MultiSelectDialogField(
              items: devices
                  .map((item) =>
                      MultiSelectItem<String>(item.id.toString(), item.name))
                  .toList(),
              title: const Text("Ara Tartım-1"),
              selectedColor: Colors.blue,
              buttonText: const Text("Ara Tartım-1"),
              onConfirm: (values) {
                setState(() {
                  selectedItems2 = values;
                  IndicatorService()
                      .saveSelections(middle1IndicatorLocal, selectedItems2);
                });
              },
              initialValue: selectedItems2, // Güncellendi
            ),
            const SizedBox(height: 20),
            MultiSelectDialogField(
              items: devices
                  .map((item) =>
                      MultiSelectItem<String>(item.id.toString(), item.name))
                  .toList(),
              title: const Text("Ara Tartım-2"),
              selectedColor: Colors.blue,
              buttonText: const Text("Ara Tartım-2"),
              onConfirm: (values) {
                setState(() {
                  selectedItems3 = values;
                  IndicatorService()
                      .saveSelections(middle2IndicatorLocal, selectedItems3);
                });
              },
              initialValue: selectedItems3, // Güncellendi
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getAllIndicators() async {
    var result = await IndicatorService().getAllIndicators();

    setState(() {
      if (result['success']) {
        devices = result['indicators'];
      } else {
        String errorMessage = result['errorMessage'];
        SnackbarHelper.showSnackbar(context, errorMessage);
      }
    });
  }
}
