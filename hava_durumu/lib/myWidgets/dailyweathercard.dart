// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class DailyWeatherCard extends StatelessWidget {
  
  final String icon;
  final double temperature;
  final String date;

  DailyWeatherCard({required this.icon, required this.temperature, required this.date});
  
  @override
  Widget build(BuildContext context) {
    List<String> gunler = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    String gun = gunler[DateTime.parse(date).weekday-1];

    return Card(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network('https://openweathermap.org/img/wn/$icon@2x.png'),
          Text('$temperature °C'),
          Text(gun),
        ],
      ),
    );
  }
}
