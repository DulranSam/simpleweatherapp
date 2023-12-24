import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather/Components/About.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController search = TextEditingController();
  var output = "";
  bool isLoading = false;

  Future<void> setWeather() async {
    const apiKey = "5b0cf8dc7a67325da249436a01c3caae";

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?q=${search.text}&appid=$apiKey&units=metric"));

      if (response.statusCode == 200) {
        final apiData = ApiData.fromJson(json.decode(response.body));
        setState(() {
          output = apiData.getData();
        });
      } else {
        setState(() {
          output = "Error: ${response.statusCode}";
        });
      }
    } catch (err) {
      setState(() {
        output = "No results found. Error: $err";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
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
            Image.network(
              "https://png.pngtree.com/png-clipart/20210418/original/pngtree-yellow-minimalist-cute-cartoon-sun-cloud-png-image_6243226.jpg",
              scale: 5,
            ),
            const Padding(padding: EdgeInsets.all(10)),
            const Text(
              "Hi, welcome to my weather app",
              style: TextStyle(fontSize: 32),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            Text(
              isLoading ? "Loading..." : output,
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
              onPressed: isLoading ? null : () => setWeather(),
              child: const Text("Search"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AboutPage(),
          ),
        ),
        hoverColor: Colors.yellow,
        child: const Icon(Icons.info_outline),
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
    return "It's ${temperature.round().toString()}° Celsius in $location";
  }
}
