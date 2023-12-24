import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController search = TextEditingController();
  var output = "";

  Future<void> setWeather() async {
    try {
      final response = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?q=${search.text}&appid=5b0cf8dc7a67325da249436a01c3caae&units=metric"));
      print('Response status: ${response.statusCode}');
      final apiData = ApiData.fromJson(json.decode(response.body));
      setState(() {
        output = apiData.getData();
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather",
          style: TextStyle(fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Hi,welcome to my weather app",
              style: TextStyle(fontSize: 32),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            Text(
              output,
              style: const TextStyle(fontSize: 32),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: search,
                style: const TextStyle(),
                decoration:
                    const InputDecoration(hintText: "Search by location"),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setWeather();
              },
              child: const Text("Search"),
            ),
          ],
        ),
      ),
    );
  }
}

class ApiData {
  late String location;
  late double temperature;

  ApiData({required this.location, required this.temperature});

  factory ApiData.fromJson(Map<String, dynamic> json) {
    return ApiData(location: json['name'], temperature: (json['main']['temp']));
  }

  String getData() {
    return "It's ${temperature.round().toString()}° celcius in $location";
  }
}
