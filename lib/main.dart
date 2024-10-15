import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart'; // For parsing the HTML
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  String? pageTitle;
  String? description;
  String? videoLink;
  String? nextLink;
  String? randomLink;

  // Fetch web content automatically on app start
  MyAppState() {
    fetchPageSource(
        'https://tasty.co/recipe/beauty-and-the-beast-inspired-french-bread-pizza');
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  Future<void> fetchPageSource(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      extractInformation(response.body);
    }
  }

  void extractInformation(String html) {
    final document = parse(html);

    final titleMeta = document.querySelector('meta[property="og:title"]');
    final descriptionMeta =
        document.querySelector('meta[property="og:description"]');

    pageTitle = titleMeta?.attributes['content'];
    description = descriptionMeta?.attributes['content'];

    final scriptTags = document.querySelectorAll('script');
    for (var script in scriptTags) {
      if (script.text.contains('video_id')) {
        final videoMatch =
            RegExp(r'"url":\s*"([^"]+)"').firstMatch(script.text);
        if (videoMatch != null) {
          videoLink = videoMatch.group(1);
        }
      }
    }

    nextLink = "https://example.com/next-link";
    randomLink = "https://example.com/random-link";

    notifyListeners();
  }

  void randVid() {
    // Logic for randVid button
    print('Random Video Button Pressed');
  }

  void simVid() {
    // Logic for simVid button
    print('Similar Video Button Pressed');
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(title: Text('Tinder but for Food')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  appState.randVid(); // Call randVid function
                },
                child: Text('Random Video'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  appState.simVid(); // Call simVid function
                },
                child: Text('Similar Video'),
              ),
              const SizedBox(height: 20),
              if (appState.pageTitle != null) ...[
                Text('Fetched Title: ${appState.pageTitle}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('Description: ${appState.description}'),
                const SizedBox(height: 10),
                Text('Video Link: ${appState.videoLink ?? "No video found"}'),
                const SizedBox(height: 10),
                Text('Next Link: ${appState.nextLink ?? "No next link found"}'),
                const SizedBox(height: 10),
                Text(
                    'Random Link: ${appState.randomLink ?? "No random link found"}'),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
