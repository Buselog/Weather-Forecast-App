// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedCity = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/search.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  onChanged: (value) {
                    selectedCity = value;
                  },
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30),
                  decoration: InputDecoration(
                      hintText: 'Şehir seçiniz', border: InputBorder.none),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final response = await http.get(
                    Uri.parse(
                        'https://api.openweathermap.org/data/2.5/weather?q=$selectedCity&appid=17bd58d9fd7b4316f86d8d213cdb4ade&units=metric'),
                  );
                  if (response.statusCode == 200) {
                    Navigator.pop(context, selectedCity);
                  } else {
                    showMyDialog();
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(),
                  backgroundColor: Colors.transparent,
                  elevation: 0.019,
                  side: BorderSide.none,
                ),
                child: Text(
                  'Select City',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

   Future<void> showMyDialog() async{
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         actions: [
           TextButton(
             onPressed: () {},
             child: Text('Ok'),
           ),
         ],
         title: Text('Location Not Found'),
         contentPadding: EdgeInsets.all(20),
         content: Text(
             'Please retry.'),
       ),
     );
   }
}
