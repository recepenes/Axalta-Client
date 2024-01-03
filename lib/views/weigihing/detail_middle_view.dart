import 'package:axalta/model/weighing_detail_dto.dart';
import 'package:axalta/model/weighing_product_dto.dart';
import 'package:axalta/services/weight/detail_service.dart';
import 'package:axalta/services/weight/weight_service.dart';
import 'package:axalta/views/snack_bar_helper.dart';
import 'package:flutter/material.dart';

class DetailMiddeleView extends StatefulWidget {
  final WeighingDetailDto dto;
  final int mixNoFinish;

  const DetailMiddeleView({
    super.key,
    required this.dto,
    required this.mixNoFinish,
  });

  @override
  State<DetailMiddeleView> createState() => _DetailMiddeleViewState();
}

class _DetailMiddeleViewState extends State<DetailMiddeleView> {
  List<WeighingProductDto> details = List.empty();

  getDetails() async {
    var result = await DetailService().getDetailsBetweenMix(
      widget.dto,
      widget.mixNoFinish,
    );

    if (result['success']) {
      details = result['details'];
    } else {
      String errorMessage = result['errorMessage'];
      SnackbarHelper.showSnackbar(context, errorMessage);
    }
  }

  List<DataRow> getTableRowData() {
    List<DataRow> response = List<DataRow>.empty(growable: true);

    for (var x in details) {
      response.add(DataRow(
        cells: [
          DataCell(Text(x.sequenceNumber.toString())),
          DataCell(Text(x.mixNo.toString())),
          DataCell(Text(x.productNumber)),
          DataCell(Text(x.weight.toString())),
          DataCell(
            ElevatedButton(
              onPressed: () async {
                WeighingDetailDto deletingDto = WeighingDetailDto(
                    batchNo: x.batchNo,
                    lineNumber: x.lineNumber,
                    mixNo: x.mixNo);
                var result = await ApiService()
                    .deleteRecord(deletingDto, x.productNumber);
                if (result['success']) {
                  SnackbarHelper.showSnackbar(context, "Başarıyla Silindi");
                } else {
                  String errorMessage = result['errorMessage'];
                  SnackbarHelper.showSnackbar(context, errorMessage);
                }
              },
              child: const Text('Sil'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(20, 30),
              ),
            ),
          ),
        ],
      ));
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tartım Detayları"),
      ),
      body: FutureBuilder(
        future: getDetails(),
        builder: (context, snapshot) {
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.grey[400],
                  child: DataTable(
                    columnSpacing: 10,
                    columns: const [
                      DataColumn(
                        label: Text('Sıra', style: TextStyle(fontSize: 13)),
                        tooltip: 'Sıra',
                      ),
                      DataColumn(
                        label: Text('MixNo', style: TextStyle(fontSize: 13)),
                        tooltip: 'MixNo',
                      ),
                      DataColumn(
                          label: Text('Ürün Kodu',
                              style: TextStyle(fontSize: 13))),
                      DataColumn(
                          label:
                              Text('Ağırlık', style: TextStyle(fontSize: 13))),
                      DataColumn(
                          label: Text('Sil', style: TextStyle(fontSize: 13)))
                    ],
                    rows: getTableRowData(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
