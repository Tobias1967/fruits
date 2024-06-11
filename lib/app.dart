import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frucht Details',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FruitScreen(),
    );
  }
}

class FruitScreen extends StatefulWidget {
  const FruitScreen({super.key});

  @override
// ignore: library_private_types_in_public_api
  _FruitScreenState createState() => _FruitScreenState();
}

class _FruitScreenState extends State<FruitScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic>? allFruits;
  Map<String, dynamic>? fruitData;
  bool isLoading = false;

  Future<void> _fetchFruits() async {
    if (allFruits == null) {
      // Caches the result
      setState(() {
        isLoading = true;
      });
      try {
        final response =
            await http.get(Uri.parse('fruityvice.com/api/fruit/all'));
        if (response.statusCode == 200) {
          allFruits = jsonDecode(response.body);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Fehler beim Abrufen der Daten: ${response.statusCode}'),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ein Fehler ist aufgetreten: $e'),
        ));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _findFruit(String name) {
    if (allFruits != null) {
      setState(() {
        fruitData = allFruits!.firstWhere(
          (fruit) =>
              fruit['name'].toString().toLowerCase() == name.toLowerCase(),
          orElse: () => null,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFruits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Json-Abfrage'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Gib den Namen einer Frucht ein',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _findFruit(_controller.text);
                }
              },
              child: const Text('Suche Fruchtdetails'),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : fruitData != null
                    ? Expanded(
                        child: ListView(
                          children: [
                            Text('Name: ${fruitData!['name']}'),
                            Text('Family: ${fruitData!['family']}'),
                            Text('Genus: ${fruitData!['genus']}'),
                            Text('Order: ${fruitData!['order']}'),
                            Text(
                                'Calories: ${fruitData!['nutritions']['calories']}'),
                            Text('Sugar: ${fruitData!['nutritions']['sugar']}'),
                          ],
                        ),
                      )
                    : const Text('Keine Daten vorhanden. Bitte Suche starten.'),
          ],
        ),
      ),
    );
  }
}
