import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather/Components/_About.dart';

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
        if (search.text.isNotEmpty) {
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
            output = "Please enter a valid city name";
          } else {
            output = "Something went wrong. Error: ${response.statusCode}";
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

  int currentIndex = 0;
  List<Widget> pages = const [HomePage(), AboutPage()];

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
              "https://static.vecteezy.com/system/resources/thumbnails/022/823/508/original/sunny-and-rainy-on-white-background-weather-animated-icon-video.jpg",
              scale: 5,
            ),
            const Padding(padding: EdgeInsets.all(10)),
            const Text(
              "Hi, welcome to my weather app",
              style: TextStyle(fontSize: 32),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            Card(
              margin: const EdgeInsets.all(25),
              child: Column(children: [
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
              ]),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            ElevatedButton(
              onPressed: isLoading ? null : () => setWeather(),
              onLongPress: () {
                print("Emergency?");
              },
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.yellow,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.question_answer), label: "About")
        ],
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
