import 'dart:async';

import 'package:axalta/enums/menu_view.dart';
import 'package:axalta/model/weighing_detail_dto.dart';
import 'package:axalta/model/weighing_product_dto.dart';
import 'package:axalta/services/indicators/indicator_service.dart';
import 'package:axalta/services/weight/weight_service.dart';
import 'package:axalta/views/snack_bar_helper.dart';
import 'package:axalta/views/weigihing/detail_middle_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../services/blue_tooth/blue_tooth_service.dart';

class MiddeleViewTwo extends StatefulWidget {
  const MiddeleViewTwo({super.key});

  @override
  State<MiddeleViewTwo> createState() => _MiddeleViewTwoState();
}

class _MiddeleViewTwoState extends State<MiddeleViewTwo> {
  late final TextEditingController _lineNo;
  late final TextEditingController _bacthNo;
  late final TextEditingController _mixNoStart;
  late final TextEditingController _mixNoFinish;
  late final TextEditingController _productNumber;
  late final TextEditingController _sequenceNo;
  late final TextEditingController _weight;
  late final TextEditingController _qrCode;
  late final TextEditingController _currentMixNoController;
  bool _isExtra = false;
  final FocusNode _focusNode = FocusNode();
  bool isButtonActive = false;
  bool isStarButtonActive = true;
  Color _backgroundColor = Colors.transparent;
  String _qrCodeLabelText = "Ürün Barkodu Okut";
  int _currentMixNo = 0;

  @override
  void initState() {
    _lineNo = TextEditingController();
    _bacthNo = TextEditingController();
    _mixNoStart = TextEditingController();
    _mixNoFinish = TextEditingController();
    _productNumber = TextEditingController();
    _sequenceNo = TextEditingController();
    _weight = TextEditingController();
    _qrCode = TextEditingController();
    _currentMixNoController = TextEditingController();
    _currentMixNoController.text = _currentMixNo.toString();
    super.initState();
  }

  @override
  void dispose() {
    _lineNo.dispose();
    _bacthNo.dispose();
    _mixNoStart.dispose();
    _productNumber.dispose();
    _sequenceNo.dispose();
    _weight.dispose();
    _qrCode.dispose();
    _currentMixNoController.dispose();
    super.dispose();
  }

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ara Tartım 2"),
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
                            FormBuilderValidators.required(
                                errorText: "Bu alan boş bırakılımaz."),
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
                            FormBuilderValidators.required(
                                errorText: "Bu alan boş bırakılımaz."),
                          ]),
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: FormBuilderTextField(
                                name: 'mixNoStart',
                                controller: _mixNoStart,
                                keyboardType: TextInputType.number,
                                maxLines: null,
                                decoration: const InputDecoration(
                                    labelText: "Mix No",
                                    contentPadding: EdgeInsets.all(8)),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(
                                      errorText: "Bu alan boş bırakılımaz."),
                                ]),
                                onEditingComplete: () {
                                  FocusScope.of(context).nextFocus();
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                              child: Text("-"),
                            ),
                            SizedBox(
                              width: 100,
                              child: FormBuilderTextField(
                                name: 'mixNoFinish',
                                controller: _mixNoFinish,
                                keyboardType: TextInputType.number,
                                maxLines: null,
                                decoration: const InputDecoration(
                                    labelText: "Mix No",
                                    contentPadding: EdgeInsets.all(8)),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(
                                      errorText: "Bu alan boş bırakılımaz."),
                                ]),
                                onEditingComplete: () {
                                  FocusScope.of(context).nextFocus();
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                              child: Text("-"),
                            ),
                            SizedBox(
                              width: 54,
                              child: FormBuilderTextField(
                                  name: 'currentMixNo',
                                  controller: _currentMixNoController,
                                  keyboardType: TextInputType.number,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                      labelText: "Güncel",
                                      contentPadding: EdgeInsets.all(8)),
                                  onChanged: (value) {
                                    if (_currentMixNoController.text != "") {
                                      _currentMixNo = int.parse(
                                          _currentMixNoController.text);
                                    }
                                  },
                                  onEditingComplete: () {
                                    FocusScope.of(context).nextFocus();
                                  }),
                            ),
                          ],
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
                        onPressed: isStarButtonActive
                            ? () async {
                                if (_formKey.currentState!.saveAndValidate()) {
                                  var result = await IndicatorService()
                                      .sendTareToIndicator(
                                          MenuViews.middleView2);
                                  if (result['success']) {
                                    SnackbarHelper.showSnackbar(
                                        context, "Dara Başarılı");
                                  } else {
                                    String errorMessage =
                                        result['errorMessage'];
                                    SnackbarHelper.showSnackbar(
                                        context, errorMessage);
                                  }
                                  _currentMixNo = int.parse(_mixNoStart.text);
                                  _currentMixNoController.text =
                                      _currentMixNo.toString();

                                  setState(() {
                                    isButtonActive = true;
                                    isStarButtonActive = false;
                                  });
                                }
                              }
                            : null,
                        child: const Text('Başla'),
                      ),
                      ElevatedButton(
                        onPressed: isButtonActive
                            ? () {
                                if (_lineNo.text.isNotEmpty &&
                                    _bacthNo.text.isNotEmpty &&
                                    _mixNoStart.text.isNotEmpty) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailMiddeleView(
                                          dto: getDetailDto(
                                              int.parse(_mixNoStart.text)),
                                          mixNoFinish:
                                              int.parse(_mixNoFinish.text),
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
                                  var result = await IndicatorService()
                                      .sendTareToIndicator(
                                          MenuViews.middleView2);
                                  if (result['success']) {
                                    SnackbarHelper.showSnackbar(
                                        context, "Dara Başarılı");
                                  } else {
                                    String errorMessage =
                                        result['errorMessage'];
                                    SnackbarHelper.showSnackbar(
                                        context, errorMessage);
                                  }
                                  _checkCurrentMixNo();
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
                  color: Colors.grey[400],
                  child: DataTable(
                    headingRowHeight: 20,
                    dataRowHeight: 20,
                    columnSpacing: 30,
                    columns: const [
                      DataColumn(
                        label: Text('Sıra', style: TextStyle(fontSize: 10)),
                        tooltip: 'Sıra',
                      ),
                      DataColumn(
                        label: Text('Mix No', style: TextStyle(fontSize: 10)),
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
                                for (int i = int.parse(_mixNoStart.text);
                                    i <= int.parse(_mixNoFinish.text);
                                    i++) {
                                  BlueToothService.setListDto(getDetailDto(i));
                                }
                                await BlueToothService.connectAndPrintList(
                                    MenuViews.middleView2);

                                for (int i = int.parse(_mixNoStart.text);
                                    i <= int.parse(_mixNoFinish.text);
                                    i++) {
                                  await ApiService()
                                      .finishRecord(getDetailDto(i));
                                }

                                var result = await IndicatorService()
                                    .sendClearToIndicator(
                                        MenuViews.middleView2);
                                if (result['success']) {
                                  SnackbarHelper.showSnackbar(
                                      context, "Clear Başarılı");
                                } else {
                                  String errorMessage = result['errorMessage'];
                                  SnackbarHelper.showSnackbar(
                                      context, errorMessage);
                                }
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
    var result = await ApiService().postData(dto, MenuViews.middleView2);

    setState(() {
      if (result['success']) {
        lastRecord = result['weighingProduct'];
      } else {
        String errorMessage = result['errorMessage'];
        SnackbarHelper.showSnackbar(context, errorMessage);
      }
    });
  }

  createNewWeighing() {}

  WeighingDetailDto getDetailDto(int _mixNo) {
    return WeighingDetailDto(
        batchNo: _bacthNo.text,
        mixNo: _mixNo,
        lineNumber: int.parse(_lineNo.text));
  }

  WeighingProductDto getWeighingDto() {
    return WeighingProductDto(
        id: 1,
        lineNumber: int.parse(_lineNo.text),
        batchNo: _bacthNo.text,
        mixNo: _currentMixNo,
        isExtra: _isExtra,
        sequenceNumber: 2,
        productNumber: _qrCode.text,
        weight: "22",
        isDone: false,
        indicatorId: 1);
  }

  void _checkCurrentMixNo() {
    _changeQrCodeBackgroundColor();

    if (_currentMixNo == int.parse(_mixNoFinish.text)) {
      _currentMixNo = int.parse(_mixNoStart.text) - 1;
      _qrCode.clear();
      setState(() {
        _backgroundColor = Colors.yellow;
      });
    }
    setState(() {
      _currentMixNo++;
      _currentMixNoController.text = (_currentMixNo.toString());
    });
  }

  void _changeQrCodeBackgroundColor() {
    setState(() {
      _backgroundColor = _backgroundColor == Colors.transparent
          ? Colors.transparent
          : Colors.transparent;
      _qrCodeLabelText = "Yeni Ürün Barkodu Okut";
    });
  }

  void _finishWeighing() {
    setState(() {
      _mixNoStart.clear();
      _mixNoFinish.clear();
      _currentMixNo = 0;
      _qrCode.clear();
      isButtonActive = false;
      isStarButtonActive = true;
      _backgroundColor = Colors.transparent;
      _qrCodeLabelText = "Ürün Barkodu Okut";
    });
  }
}
