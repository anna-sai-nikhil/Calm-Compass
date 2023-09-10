import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textEditingController = TextEditingController();
  String _prediction = '';

  Future<void> _analyzeText() async {
    final String inputText = _textEditingController.text;
    final String apiUrl = 'https://annasainikhil.pythonanywhere.com/predict';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'input_text': inputText}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        double rawPrediction = responseData['prediction']; // Assuming prediction is a double value
        String formattedPrediction = (rawPrediction * 100).toStringAsFixed(2); // Format as percentage with 2 decimal places
        _prediction = 'Your Stress level is nearly: $formattedPrediction%';
      });
    } else {
      setState(() {
        _prediction = 'Error: Unable to analyze text';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stress Predictor'),
        backgroundColor: Color(0xFF21999E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: 'Enter text to analyze your stress level',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _analyzeText,
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF0d7377),
              ),
              child: Text('Analyze Text'),
            ),
            SizedBox(height: 16.0),
            Text(_prediction),
          ],
        ),
      ),
    );
  }
}
