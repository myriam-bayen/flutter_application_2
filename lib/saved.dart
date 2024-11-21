// lib/pages/search_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/main.dart';
import 'package:url_launcher/url_launcher.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
      ),
      body: ListView.builder(
        itemCount: appState.liked_vids.length,
        itemBuilder: (context, index) {
          return ElevatedButton(
            onPressed: () async {
              final url = appState.liked_vids[index];

              // Check if the URL is valid and launch it
              if (url != null && Uri.tryParse(url)?.hasScheme == true) {
                final Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  // Handle the error or show a message
                  print('Could not launch $url');
                }
              } else {
                // Handle invalid URL
                print('Invalid URL: $url');
              }
            },
            child: Text(appState.liked_vids[index] ??
                'Unknown'), // Button title from the list
          );
        },
      ),
    );
  }
}
