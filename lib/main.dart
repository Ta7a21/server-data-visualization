import 'package:flutter/material.dart';
import 'package:d_chart/d_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
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
  String chartTitle = "Pressure";
  List<Map<String, dynamic>> data = [
    {'year': 2021, 'percent': 8},
    {'year': 2022, 'percent': 20},
    {'year': 2023, 'percent': 40},
    {'year': 2024, 'percent': 56},
    {'year': 2025, 'percent': 70}
  ];

  Future<dynamic> getData() async {
    var res = await http.get(Uri.parse('http://localhost:8433/temperature'),
        headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*"
        });
    if (res.statusCode == 200) {
      var jsonObject = json.decode(res.body);
      var data = jsonObject["data"];
      log("data:$data");
      return jsonObject["data"];
    }
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
              future: getData(),
              builder: (context, AsyncSnapshot snapshot) {
                log('deta:$snapshot');
                if (snapshot.data != null) {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 4,
                          child: ListTile(
                            title: Text(snapshot.data[index]["reading"]),
                          ),
                        );
                      });
                } else {
                  return CircularProgressIndicator();
                }
              },
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(chartTitle),
                  SizedBox(
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
                                'domain': e['year'] - 2020,
                                'measure': e['percent']
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        chartTitle = "Pressure";
                        data = [
                          {'year': 2021, 'percent': 8},
                          {'year': 2022, 'percent': 70},
                          {'year': 2023, 'percent': 90},
                          {'year': 2024, 'percent': 46},
                          {'year': 2025, 'percent': 20}
                        ];
                      });
                    },
                    child: const Text('Pressure'),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        chartTitle = "Temperature";
                        data = [
                          {'year': 2021, 'percent': 8},
                          {'year': 2022, 'percent': 20},
                          {'year': 2023, 'percent': 40},
                          {'year': 2024, 'percent': 56},
                          {'year': 2025, 'percent': 70}
                        ];
                      });
                    },
                    child: const Text('Temperature'),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
