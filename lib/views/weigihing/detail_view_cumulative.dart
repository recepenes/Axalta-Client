import 'package:axalta/model/weighing_detail_dto.dart';
import 'package:axalta/model/weighing_product_dto.dart';
import 'package:axalta/services/weight/detail_service.dart';
import 'package:axalta/views/snack_bar_helper.dart';
import 'package:flutter/material.dart';

class DetailViewCumulative extends StatefulWidget {
  final WeighingDetailDto dto;

  const DetailViewCumulative({super.key, required this.dto});

  @override
  State<DetailViewCumulative> createState() => _DetailViewCumulativeState();
}

class _DetailViewCumulativeState extends State<DetailViewCumulative> {
  List<WeighingProductDto> details = List.empty();

  getDetails() async {
    var result = await DetailService().getDetailsCumulative(widget.dto);

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
                        label: Text('Mix No', style: TextStyle(fontSize: 13)),
                      ),
                      DataColumn(
                          label: Text('Ürün Kodu',
                              style: TextStyle(fontSize: 13))),
                      DataColumn(
                          label:
                              Text('Ağırlık', style: TextStyle(fontSize: 13))),
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
