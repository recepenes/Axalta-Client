import 'package:axalta/model/weighing_detail_dto.dart';
import 'package:axalta/model/weighing_product_dto.dart';
import 'package:axalta/services/weight/weight_service.dart';
import 'package:axalta/views/weigihing/detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

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
    super.dispose();
  }

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pigment Tartım"),
      ),
      body: FutureBuilder(
        future: createNewWeighing(),
        builder: (context, snapshot) {
          return ListView(
            children: [
              Padding(
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
                        keyboardType: TextInputType.text,
                        maxLines: null,
                        decoration: const InputDecoration(
                            labelText: "Hat No",
                            contentPadding: EdgeInsets.all(8)),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
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
                      ),
                      FormBuilderTextField(
                        name: 'mixNo',
                        controller: _mixNo,
                        keyboardType: TextInputType.text,
                        maxLines: null,
                        decoration: const InputDecoration(
                            labelText: "Mix No",
                            contentPadding: EdgeInsets.all(8)),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      FormBuilderTextField(
                        name: "qrCode",
                        controller: _qrCode,
                        keyboardType: TextInputType.text,
                        maxLines: null,
                        decoration: const InputDecoration(
                            labelText: "Ürün Barkodu Okut",
                            contentPadding: EdgeInsets.all(8)),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
                  color: Colors.grey[400],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Birinci butonun işlevi
                        },
                        child: const Text('Başla'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.saveAndValidate()) {
                            WeighingDetailDto dto = WeighingDetailDto(
                                batchNo: _bacthNo.text,
                                mixNo: int.parse(_mixNo.text),
                                lineNumber: int.parse(_lineNo.text));

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailView(dto: dto),
                                ));
                          }
                        },
                        child: const Text('Detay'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.saveAndValidate()) {
                            // Form is valid, perform your actions here
                            WeighingProductDto dto = WeighingProductDto(
                                id: 1,
                                lineNumber: int.parse(_lineNo.text),
                                batchNo: _bacthNo.text,
                                mixNo: int.parse(_mixNo.text),
                                isExtra: _isExtra,
                                sequenceNumber: 2,
                                productNumber: _qrCode.text,
                                weight: "22",
                                isDone: false);

                            recordWeight(dto);
                          }
                        },
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
                child: Container(
                  height: 50,
                  color: Colors.grey[400],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Birinci butonun işlevi
                        },
                        child: const Text('Duraklat'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // İkinci butonun işlevi
                        },
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
}
