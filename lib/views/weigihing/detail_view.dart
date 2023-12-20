import 'package:axalta/model/weighing_detail_dto.dart';
import 'package:axalta/model/weighing_product_dto.dart';
import 'package:axalta/services/weight/detail_service.dart';
import 'package:flutter/material.dart';

class DetailView extends StatefulWidget {
  final WeighingDetailDto dto;

  DetailView({super.key, required this.dto});

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  List<WeighingProductDto> details = List.empty();

  getDetails() async {
    details = await DetailService().getDetails(widget.dto);
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
                    columns: const [
                      DataColumn(
                        label: Text('Sıra', style: TextStyle(fontSize: 15)),
                        tooltip: 'Sıra',
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
