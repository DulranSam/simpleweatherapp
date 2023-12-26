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
        if (search.text != "") {
          setState(() {
            output = apiData.getData();
          });
        } else {
          setState(() {
            output = "Please enter a city";
          });
        }
      } else {
        setState(() {
          if (response.statusCode == 400) {
            output = "Please enter City Name";
          } else {
            output = "Something went wrong";
          }
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
  late List<String> weather;
  late double windspeed;
  late String description;
  late String country;

  ApiData({
    required this.location,
    required this.description,
    required this.temperature,
    required this.weather,
    required this.windspeed,
    required this.country,
  });

  factory ApiData.fromJson(Map<String, dynamic> json) {
    return ApiData(
      location: json['name'],
      description: json["weather"][0]["description"],
      temperature: (json['main']['temp']),
      weather: [(json["weather"][0]["main"])],
      windspeed: json["wind"]["speed"],
      country: json["sys"]["country"],
    );
  }

  String getData() {
    String weatherDescription = weather.join(" , ");
    return "$weatherDescription, more like $description\nIt's ${temperature.round().toString()}° Celsius in $location\n Wind Speed : $windspeed m \n in $country";
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
      ),
      body: const Center(
        child: Text("This is the about page."),
      ),
    );
  }
}
