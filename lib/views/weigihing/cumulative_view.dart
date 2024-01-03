import 'package:axalta/model/weighing_detail_dto.dart';
import 'package:axalta/services/blue_tooth/blue_tooth_service.dart';
import 'package:axalta/views/weigihing/detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class CumulativeView extends StatefulWidget {
  const CumulativeView({super.key});

  @override
  State<CumulativeView> createState() => _CumulativeViewState();
}

class _CumulativeViewState extends State<CumulativeView> {
  late final TextEditingController _lineNo;
  late final TextEditingController _bacthNo;
  late final TextEditingController _mixNo;
  bool isButtonActive = false;

  @override
  void initState() {
    _lineNo = TextEditingController();
    _bacthNo = TextEditingController();
    _mixNo = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _lineNo.dispose();
    _bacthNo.dispose();
    _mixNo.dispose();
    super.dispose();
  }

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kümülatif Çıktı"),
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
                      FormBuilderTextField(
                        name: 'mixNo',
                        controller: _mixNo,
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
                    ],
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
                          if (_formKey.currentState!.saveAndValidate()) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailView(
                                    dto: getDetailDto(),
                                  ),
                                ));
                          }
                        },
                        child: const Text('Detay'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.saveAndValidate()) {
                            BlueToothService.setDto(getDetailDto());
                            await BlueToothService.startTimer();
                          }
                        },
                        child: const Text('Çıktı Al'),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  createNewWeighing() {}

  WeighingDetailDto getDetailDto() {
    return WeighingDetailDto(
        batchNo: _bacthNo.text,
        mixNo: int.parse(_mixNo.text),
        lineNumber: int.parse(_lineNo.text));
  }
}
