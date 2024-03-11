// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hava_durumu/searchpage.dart';
import 'package:http/http.dart' as http;
//import 'package:intl/intl.dart';

import 'myWidgets/dailyweathercard.dart';
import 'myWidgets/loading_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String location = 'Ankara';
  double? tempreture;
  final String userId = '17bd58d9fd7b4316f86d8d213cdb4ade';
  var locationData;
  String codeImage = 'c';
  Position? devicePosition;
  String icon = '';

  List<String> icons = ['01d', '01d', '01d', '01d', '01d'];
  List<double> tempretures = [1, 2, 3, 4, 5];
  List<String> days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma'];

  Future<void> getLocationData() async {
    locationData = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$userId&units=metric'),
    );
    final locationDataParsed =
        jsonDecode(locationData.body); // string jSon'u düzgün Map'ledik.

    setState(() {
      tempreture = locationDataParsed['main']['temp'];
      location = locationDataParsed['name'];
      codeImage = locationDataParsed['weather'][0]['main'];
      icon = locationDataParsed['weather'][0]['icon'];
    });
  }

  Future<void> getLocationDataByLatLon() async {
    if (devicePosition != null) {
      locationData = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$userId&units=metric'),
      );
      final locationDataParsed =
          jsonDecode(locationData.body); // string jSon'u düzgün Map'ledik.

      setState(() {
        tempreture = locationDataParsed['main']['temp'];
        location = locationDataParsed['name'];
        codeImage = locationDataParsed['weather'][0]['main'];
        icon = locationDataParsed['weather'][0]['icon'];
      });
    }
  }

  //GPS, telefonun bulunduğu şehir konumu ile uygulama açıldığında oranın hava verisi açılsın diye.
  Future<void> getDevicePosition() async {
    devicePosition = await _determinePosition();
  }

  Future<void> getDailyForecastByLatLon() async {
    var forecastData = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$userId&units=metric'),
    );
    final forecastDataParsed = jsonDecode(forecastData.body);

    tempretures.clear();
    icons.clear();
    days.clear();
    setState(() {
      for (int i = 7; i <= 39; i += 8) {
        tempretures.add(forecastDataParsed['list'][i]['main']['temp']);
        icons.add(forecastDataParsed['list'][i]['weather'][0]['icon']);
        days.add(forecastDataParsed['list'][i]['dt_txt']);
      }
    });
  }

  // şehri biz girdikten sonra telefon konumunun 5 günlük tahmini aynı kalır. Bunu, arama yaptığımız şehir için göstermek istersek
  Future<void> getDailyForecastByAPI() async {
    var forecastData = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$userId&units=metric'),
    );
    final forecastDataParsed = jsonDecode(forecastData.body);

    tempretures.clear();
    icons.clear();
    days.clear();

    setState(() {
      for (int i = 7; i <= 39; i += 8) {
        tempretures.add(forecastDataParsed['list'][i]['main']['temp']);
        icons.add(forecastDataParsed['list'][i]['weather'][0]['icon']);
        days.add(forecastDataParsed['list'[i]]['dt_txt']);
      }
    });
  }

  void getInitialData() async {
    await getDevicePosition();
    await getLocationDataByLatLon(); //Current weather data
    await getDailyForecastByLatLon(); // forecast for 5 days
  }

  @override
  void initState() {
    // bu fonksiyon içine await kullanılmamalı.
    getInitialData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration containerDecoration = BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/$codeImage.jpg'),
        fit: BoxFit.cover, // resim, tüm farklı cihazlarda ekranı kaplasın
      ),
    );
    return Container(
      decoration: containerDecoration,
      child: tempreture == null ||
              devicePosition == null ||
              icons.isEmpty ||
              tempretures.isEmpty ||
              days.isEmpty
          ? LoadingWidget()
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // await = fonksiyonun değer döndürmesini, çekmesini bekle, sonra print yap
                      // diğer türlü son print çalışır ve null döndürür.
                      // çünkü biz bir üst satırda datanın çekilmesini beklemedik.
                      // bu nedenle fonksiyonun önüne await ekledik ve onun işlemi bitene kadar bekledik.
                      // await kullandığımız için fonksiyonu ASYNC olarak işaretledik.
                      // data çekildi ve RESPONE, yani yanıt alındı.
                      // Bu response içinden işimize yarayan datayı kullanacağız.

                      SizedBox(
                        height: 150,
                        child: Image.network(
                            'https://openweathermap.org/img/wn/$icon@4x.png'),
                      ),
                      Text(
                        '$tempreture °C',
                        style: TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 3, // bulanıklık oranı
                              offset: Offset(3, 10), // hangi taraf
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            location.toString(),
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () async {
                              final selectedCity = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchPage(),
                                ),
                              );
                              location = selectedCity;
                              getLocationData();
                              getDailyForecastByAPI();
                            },
                            icon: Icon(
                              Icons.search,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      buildWeatherCards(context),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  SizedBox buildWeatherCards(BuildContext context) {
    List<DailyWeatherCard> cards = [];

    for (int i = 0; i < 5; i++) {
      cards.add(
        DailyWeatherCard(
            icon: icons[i], temperature: tempretures[i], date: days[i]),
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.24,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: cards,
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
