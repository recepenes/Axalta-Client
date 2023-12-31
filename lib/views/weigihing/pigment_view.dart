import 'dart:async';

import 'package:axalta/model/weighing_detail_dto.dart';
import 'package:axalta/model/weighing_product_dto.dart';
import 'package:axalta/services/indicators/indicator_service.dart';
import 'package:axalta/services/weight/weight_service.dart';
import 'package:axalta/views/weigihing/detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../services/blue_tooth/blue_tooth_service.dart';

class PigmentView extends StatefulWidget {
  const PigmentView({super.key});

  @override
  State<PigmentView> createState() => _PigmentViewState();
}

class _PigmentViewState extends State<PigmentView> {
  late final TextEditingController _lineNo;
  late final TextEditingController _bacthNo;
  late final TextEditingController _mixNo;
  late final TextEditingController _productNumber;
  late final TextEditingController _sequenceNo;
  late final TextEditingController _weight;
  late final TextEditingController _qrCode;
  bool _isExtra = false;
  final FocusNode _focusNode = FocusNode();
  bool isButtonActive = false;
  Color _backgroundColor = Colors.transparent;
  String _qrCodeLabelText = "Ürün Barkodu Okut";
  bool _isBTDeviceActive = false;
  late Timer _timer;

  @override
  void initState() {
    _lineNo = TextEditingController();
    _bacthNo = TextEditingController();
    _mixNo = TextEditingController();
    _productNumber = TextEditingController();
    _sequenceNo = TextEditingController();
    _weight = TextEditingController();
    _qrCode = TextEditingController();
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _lineNo.dispose();
    _bacthNo.dispose();
    _mixNo.dispose();
    _productNumber.dispose();
    _sequenceNo.dispose();
    _weight.dispose();
    _qrCode.dispose();
    _timer.cancel();
    super.dispose();
  }

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pigment Tartım"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(
              Icons.print_sharp,
              color: _isBTDeviceActive ? Colors.green : Colors.red,
            ),
          )
        ],
      ),
      body: FutureBuilder(
        future: createNewWeighing(),
        builder: (context, snapshot) {
          return ListView(
            children: [
              RawKeyboardListener(
                autofocus: true,
                focusNode: FocusNode(),
                onKey: (RawKeyEvent event) {
                  if (event.logicalKey.debugName == "TV Satellite Toggle" ||
                      event.logicalKey.debugName == "TV Antenna Cable" ||
                      event.logicalKey.debugName == "TV Network") {
                    FocusScope.of(context).requestFocus(_focusNode);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FormBuilder(
                    key: _formKey,
                    // height: 150,
                    //color: Colors.grey[400],
                    child: Column(
                      children: [
                        FormBuilderTextField(
                          name: 'lineNo',
                          controller: _lineNo,
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          decoration: const InputDecoration(
                              labelText: "Hat No",
                              contentPadding: EdgeInsets.all(8)),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        FormBuilderTextField(
                          name: 'batchNo',
                          controller: _bacthNo,
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          decoration: const InputDecoration(
                              labelText: "Batch No",
                              contentPadding: EdgeInsets.all(8)),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        FormBuilderTextField(
                          name: 'mixNo',
                          controller: _mixNo,
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          decoration: const InputDecoration(
                              labelText: "Mix No",
                              contentPadding: EdgeInsets.all(8)),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        FormBuilderTextField(
                          name: "qrCode",
                          controller: _qrCode,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: _qrCodeLabelText,
                            contentPadding: const EdgeInsets.all(8),
                            filled: true,
                            fillColor: _backgroundColor,
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        CheckboxListTile(
                          title: const Text('İlave Tartım'),
                          value: _isExtra,
                          onChanged: (bool? value) {
                            setState(() {
                              _isExtra = value ?? false;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Birinci butonun işlevi
                          IndicatorService().sendTareToIndicator();
                          setState(() {
                            isButtonActive = true;
                          });
                        },
                        child: const Text('Başla'),
                      ),
                      ElevatedButton(
                        onPressed: isButtonActive
                            ? () {
                                if (_lineNo.text.isNotEmpty &&
                                    _bacthNo.text.isNotEmpty &&
                                    _mixNo.text.isNotEmpty) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailView(
                                          dto: getDetailDto(),
                                        ),
                                      ));
                                }
                              }
                            : null,
                        child: const Text('Detay'),
                      ),
                      ElevatedButton(
                        onPressed: isButtonActive
                            ? () async {
                                if (_formKey.currentState!.saveAndValidate()) {
                                  await recordWeight(getWeighingDto());
                                  await IndicatorService()
                                      .sendTareToIndicator();
                                  _changeQrCodeBackgroundColor();
                                }
                              }
                            : null,
                        child: const Text('Ok'),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 40,
                  color: Colors.grey[400],
                  child: DataTable(
                    headingRowHeight: 20,
                    dataRowHeight: 20,
                    columns: const [
                      DataColumn(
                        label: Text('Sıra', style: TextStyle(fontSize: 10)),
                        tooltip: 'Sıra',
                      ),
                      DataColumn(
                          label: Text('Ürün Kodu',
                              style: TextStyle(fontSize: 10))),
                      DataColumn(
                          label:
                              Text('Ağırlık', style: TextStyle(fontSize: 10))),
                    ],
                    rows: getTableRowData(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: isButtonActive
                            ? () {
                                // Birinci butonun işlevi
                                Navigator.pop(context);
                              }
                            : null,
                        child: const Text('Duraklat'),
                      ),
                      ElevatedButton(
                        onPressed: isButtonActive
                            ? () async {
                                await ApiService().finishRecord(getDetailDto());
                                BlueToothService().setDto(getDetailDto());
                                await BlueToothService().startTimer();
                                _finishWeighing();
                              }
                            : null,
                        child: const Text('Tartımı Bitir'),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  WeighingProductDto lastRecord = WeighingProductDto.empty();

  List<DataRow> getTableRowData() {
    List<DataRow> rows = List<DataRow>.empty(growable: true);

    rows.add(lastRecord.getRows());
    return rows;
  }

  Future recordWeight(WeighingProductDto dto) async {
    _qrCode.clear();

    var mock = await ApiService().postData(dto);
    setState(() {
      lastRecord = mock;
    });
  }

  createNewWeighing() {}

  WeighingDetailDto getDetailDto() {
    return WeighingDetailDto(
        batchNo: _bacthNo.text,
        mixNo: int.parse(_mixNo.text),
        lineNumber: int.parse(_lineNo.text));
  }

  WeighingProductDto getWeighingDto() {
    return WeighingProductDto(
        id: 1,
        lineNumber: int.parse(_lineNo.text),
        batchNo: _bacthNo.text,
        mixNo: int.parse(_mixNo.text),
        isExtra: _isExtra,
        sequenceNumber: 2,
        productNumber: _qrCode.text,
        weight: "22",
        isDone: false);
  }

  void _changeQrCodeBackgroundColor() {
    setState(() {
      _backgroundColor = _backgroundColor == Colors.transparent
          ? Colors.yellow
          : Colors.yellow;
      _qrCodeLabelText = "Yeni Ürün Barkodu Okut";
    });
  }

  void _finishWeighing() {
    setState(() {
      _lineNo.clear();
      _bacthNo.clear();
      _mixNo.clear();
      _qrCode.clear();
      isButtonActive = false;
      _backgroundColor = Colors.transparent;
      _qrCodeLabelText = "Ürün Barkodu Okut";
    });
  }

  void _startTimer() async {
    // Timer'ı 5 saniyede bir çalıştırmak için ayarlayın
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      // Burada her 5 saniyede bir çalışmasını istediğiniz işlemi gerçekleştirin
      setState(() {
        _isBTDeviceActive = BlueToothService().getStatus();
        ;
      });
    });
  }
}
