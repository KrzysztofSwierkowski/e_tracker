import 'package:flutter/material.dart';
import 'package:phone_mqtt/constans.dart' as Constans;

class GpsDevicesList extends StatefulWidget {
  const GpsDevicesList({super.key});

  @override
  _GpsDevicesListState createState() => _GpsDevicesListState();
}

class _GpsDevicesListState extends State<GpsDevicesList> {
  List<String> items = Constans.deviceIDList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Lista zapisanych Id urządzeń:"),
          Text("Przesuń w prawo by usunąć"),
          ListView.builder(
            itemCount: items.length,
            prototypeItem: ListTile(
              title: Text(items.first),
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: Key(item),
                onDismissed: (direction) {
                  setState(() {
                    items.removeAt(index);
                  });

                  // Then show a snackbar.
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('$item dismissed')));
                },
                child: ListTile(
                  leading: const Icon(Icons.list),
                  title: Text(item),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
