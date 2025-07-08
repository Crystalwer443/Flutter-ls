import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _currencies = ['USD', 'EUR', 'KZT', 'GBP', 'JPY'];
  String _from = 'USD';
  String _to = 'EUR';
  double? _convertedAmount;
  Map<String, dynamic> _rates = {};

  Future<void> fetchRates() async {
    final url = Uri.parse('https://api.exchangerate.host/latest?base=$_from');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _rates = data['rates'];
      });
    }
  }

  void convert() {
    final input = double.tryParse(_controller.text);
    if (input != null && _rates.containsKey(_to)) {
      final rate = _rates[_to];
      setState(() {
        _convertedAmount = input * rate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Converter')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _from,
                    isExpanded: true,
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _from = value;
                          fetchRates();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.swap_horiz),
                const SizedBox(width: 20),
                Expanded(
                  child: DropdownButton<String>(
                    value: _to,
                    isExpanded: true,
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _to = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: convert, child: const Text('Convert')),
            const SizedBox(height: 20),
            if (_convertedAmount != null)
              Text(
                'Result: ${_convertedAmount!.toStringAsFixed(2)} $_to',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
