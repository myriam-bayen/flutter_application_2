// lib/pages/search_page.dart

import 'package:flutter/material.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});
  @override
  Widget build(BuildContext context) {
    List<String> items = [
      'Apple',
      'Banana',
      'Cherry',
      'Date',
      'Elderberry'
    ]; // List of items
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
      ),
      body: Expanded(
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              onPressed: () {
                // Action when the button is pressed
                print('Button pressed: ${items[index]}');
              },
              child: Text(items[index]), // Button title from the list
            );
          },
        ),
      ),
    );
  }
}
