import 'package:axalta/model/weighing_detail_dto.dart';
import 'package:axalta/model/weighing_product_dto.dart';
import 'package:axalta/services/weight/detail_service.dart';
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
    details = await DetailService().getDetailsBetweenMix(
      widget.dto,
      widget.mixNoFinish,
    );
  }

  List<DataRow> getTableRowData() {
    List<DataRow> response = List<DataRow>.empty(growable: true);

    for (var x in details) {
      response.add(x.getRows());
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
                    headingRowHeight: 20,
                    dataRowHeight: 30,
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(
                        label: Text('Sıra', style: TextStyle(fontSize: 15)),
                        tooltip: 'Sıra',
                      ),
                      DataColumn(
                        label: Text('MixNo', style: TextStyle(fontSize: 15)),
                        tooltip: 'MixNo',
                      ),
                      DataColumn(
                          label: Text('Ürün Kodu',
                              style: TextStyle(fontSize: 15))),
                      DataColumn(
                          label:
                              Text('Ağırlık', style: TextStyle(fontSize: 15))),
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
