import 'package:axalta/constants/indicator.dart';
import 'package:axalta/model/indicator_dto.dart';
import 'package:axalta/services/indicators/indicator_service.dart';
import 'package:axalta/views/snack_bar_helper.dart';
import 'package:flutter/material.dart';

class IndicatorView extends StatefulWidget {
  const IndicatorView({super.key});

  @override
  State<IndicatorView> createState() => _IndicatorViewState();
}

class _IndicatorViewState extends State<IndicatorView> {
  @override
  void initState() {
    super.initState();
  }

  List<IndicatorDto> devices = List<IndicatorDto>.empty(growable: true);
  IndicatorDto localIndicator = IndicatorDto.empy();

  void updateLocalIndicator() async {
    var sad = await IndicatorService().getSavedIndicator();
    setState(() {
      localIndicator = sad;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tartım Platform Ayarlar"),
      ),
      body: FutureBuilder(
        future: (openCustom()),
        builder: (context, snapshot) {
          return Column(
            children: [
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
                            Icons.balance,
                            color: localIndicator.name.isNotEmpty
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                      ListTile(
                        minVerticalPadding: 5,
                        dense: true,
                        title: localIndicator.name.isNotEmpty
                            ? Center(
                                child:
                                    Text('Terazi Adı: ${localIndicator.name}'))
                            : const Center(child: Text("Secili cihaz yok")),
                        subtitle: localIndicator.name.isNotEmpty
                            ? Center(
                                child: Text(
                                    'Terazi Id: ${localIndicator.id.toString()}'))
                            : const Center(child: Text("Secili cihaz yok")),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text("Seçilebilir Tartim Cihazları"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Card(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    height: 180,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: devices.length > 0 ? devices.length : 0,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.balance),
                          onTap: () async {
                            await IndicatorService().saveIndicatorIdToDevice(
                                devices[index].id, devices[index].name);
                            indicatorId = devices[index].id;
                            indicatorName = devices[index].name;
                            updateLocalIndicator();
                          },
                          title: Text(
                              '${devices[index].id} - ${devices[index].name}'),
                          subtitle: const Text("Lütfen terazi seçin"),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  openCustom() async {
    await getAllIndicators();
    await getLocalIndicator();
  }

  getAllIndicators() async {
    var result = await IndicatorService().getAllIndicators();

    if (result['success']) {
      devices = result['indicators'];
    } else {
      String errorMessage = result['errorMessage'];
      SnackbarHelper.showSnackbar(context, errorMessage);
    }
  }

  Future getLocalIndicator() async {
    localIndicator = await IndicatorService().getSavedIndicator();
  }
}
