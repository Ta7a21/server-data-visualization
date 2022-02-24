import 'package:flutter/material.dart';
import 'package:d_chart/d_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:quiver/async.dart';

void main() {
  runApp(const MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String chartTitle = "";
  List<Map<String, dynamic>> data = [];

  getTemperature() async {
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

  getPressure() async {
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

  final int _start = 1000;
  int _current = 1000;
  late CountdownTimer countDownTimer;

  CountdownTimer startTimer(String sensor) {
    CountdownTimer countDownTimer = CountdownTimer(
      Duration(seconds: _start),
      const Duration(seconds: 2),
    );
    var sub = countDownTimer.listen(null);
    sub.onData((duration) async {
      var tempData;
      if (sensor == "temperature") {
        tempData = await getTemperature();
      } else {
        tempData = await getPressure();
      }
      setState(() {
        _current = _start - duration.elapsed.inSeconds;

        var length = tempData.length;
        data.clear();
        for (int i = 0; i < length; ++i) {
          data.add({
            'id': tempData[i]["id"],
            'reading': tempData[i]["reading"],
            'time': tempData[i]["time"]
          });
        }
      });
    });

    sub.onDone(() {
      sub.cancel();
    });

    return countDownTimer;
  }

  @override
  void initState() {
    super.initState();
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      chartTitle = "Pressure";
                      // countDownTimer = startTimer("pressure");
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
                    onPressed: () async {
                      chartTitle = "Temperature";
                      // countDownTimer = startTimer("temperature");
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
