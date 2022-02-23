import 'package:flutter/material.dart';
import 'package:d_chart/d_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

void main() {
  runApp(const MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<dynamic> _futureData;
  List<Map<String, dynamic>> data = [
    // {'year': 2021, 'percent': 8},
    // {'year': 2022, 'percent': 20},
    // {'year': 2023, 'percent': 40},
    // {'year': 2024, 'percent': 56},
    // {'year': 2025, 'percent': 70}
  ];

  Future<dynamic> getTemperature() async {
    var res = await http.get(Uri.parse('http://localhost:8433/temperature'),
        headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*"
        });
    if (res.statusCode == 200) {
      var jsonObject = json.decode(res.body);
      return jsonObject["data"];
    }
  }

  Future<dynamic> getPressure() async {
    var res = await http.get(Uri.parse('http://localhost:8433/pressure'),
        headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*"
        });
    if (res.statusCode == 200) {
      var jsonObject = json.decode(res.body);
      return jsonObject["data"];
    }
  }

  @override
  void initState() {
    super.initState();
    _futureData = getTemperature();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP32 Data Graph'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FutureBuilder(
                future: _futureData,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.data != null) {
                    var length = snapshot.data.length;
                    data.clear();
                    for (int i = 0; i < length; ++i) {
                      data.add({
                        'id': snapshot.data[i]["id"],
                        'reading': snapshot.data[i]["reading"],
                        'time': snapshot.data[i]["time"]
                      });
                    }
                    return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                            child: ListTile(
                              title: Text(snapshot.data[index]["time"]),
                            ),
                          );
                        });
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text("Pressure"),
                  Container(
                    width: 500,
                    height: 500,
                    child: AspectRatio(
                      aspectRatio: 1 / 3,
                      child: DChartLine(
                        data: [
                          {
                            'id': 'Line',
                            'data': data.map((e) {
                              return {
                                'domain': e['reading'],
                                'measure': e['id']
                              };
                            }).toList()
                          },
                        ],
                        lineColor: (lineData, index, id) => Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _futureData = getPressure();
                    });
                  },
                  child: const Text('Pressure'),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _futureData = getTemperature();
                    });
                  },
                  child: const Text('Temperature'),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
