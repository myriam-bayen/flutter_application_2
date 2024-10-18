import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse; // For parsing the HTML
import 'dart:convert';
import 'dart:math';

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
  List<String> tags = [];
  String? description;
  String? videoLink;
  String? nextLink;
  String? randomLink;
  String? prettyPrintTags;
  List<String> selectedTags = [];
  String? formattedSelectedTags;
  List<String> importantTags = [
    // Ingredients
    'chicken', 'beef', 'pork', 'lamb', 'turkey', 'fish', 'shrimp', 'salmon',
    'tuna',
    'tofu', 'lentils', 'beans', 'chickpeas', 'tomatoes', 'potatoes',
    'mushrooms',
    'garlic', 'onion', 'carrots', 'bell peppers', 'spinach', 'kale', 'broccoli',
    'cauliflower', 'pumpkin', 'zucchini', 'sweet potatoes', 'cheese', 'eggs',
    'butter',
    // Dish Types
    'soup', 'stews', 'salad', 'pasta', 'sandwich', 'burger', 'pizza',
    'casserole',
    'stir-fry', 'curry', 'roast', 'grilled', 'baked', 'fried', 'braised',
    'sautéed',
    'slow-cooked', 'barbecue', 'sushi', 'tacos', 'wraps', 'quiche', 'pie',
    'pastry',
    'bread', 'pancakes', 'waffles', 'muffins', 'cake', 'cookies', 'vegetables',
    // Cuisines
    'italian', 'mexican', 'chinese', 'indian', 'french', 'japanese', 'thai',
    'greek',
    'mediterranean', 'middle eastern', 'korean', 'american', 'southern (u.s.)',
    'vietnamese',
    // Cooking Methods
    'oven-baked', 'pan-fried', 'deep-fried', 'grilled', 'smoked', 'sous-vide',
    'air-fried', 'roasted', 'pressure-cooked', 'boiled', 'poached', 'steamed',
    'quick',
    // Dietary Preferences
    'vegetarian', 'vegan', 'gluten-free', 'dairy-free', 'low-carb', 'keto',
    'paleo',
    'whole30', 'pescatarian',
    // Themes & Occasions
    'halloween', 'christmas', 'thanksgiving', 'easter', 'summer', 'winter',
    'comfort food', 'game day', 'potluck', 'kid-friendly', 'fall', 'spring',
    'dinner',
    'snack', 'jewish', 'comfort_food',
    // Other Relevant Tags
    'spicy', 'sweet', 'savory', 'tangy', 'crunchy', 'warm', 'cozy', 'cold',
    'refreshing', 'drink'
  ];

  // Fetch web content automatically on app start
  MyAppState() {
    _init();
  }

  Future<void> _init() async {
    String result = await randVid(); // Await the result of randVid
    print(result);
    fetchPageSource(result); // Now you can pass the result
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
      if (script.text.contains('window.BFADS =')) {
        RegExp tagPattern = RegExp(r'"cms_tags":\s*\[(.*?)\]');
        var match = tagPattern.firstMatch(script.text);
        if (match != null) {
          String tagString = match.group(1)!;
          tags = tagString
              .split(',')
              .map((tag) => tag.trim().replaceAll('"', ''))
              .toList();
        }
      }
    }

    selectedTags =
        tags.where((tag) => importantTags.contains(tag.toLowerCase())).toList();
    print(selectedTags);

    // Format the selected tags
    formattedSelectedTags = selectedTags.join('+');
    prettyPrintTags = selectedTags.join(', ');

    nextLink = "https://example.com/next-link";
    randomLink = "https://example.com/random-link";

    notifyListeners();
  }

  Future<String> randVid() async {
    String randLink = "https://tasty.co/search?q=" +
        randIndex() +
        "+" +
        randIndex() +
        "&sort=popular";
    //print("randLink:" + randLink);
    var response = await http.get(Uri.parse(randLink));
    if (response.statusCode == 200) {
      var document = parse(response.body);

      // Extract the link using the CSS selector
      var element = document.querySelector("#search-results-feed li a");
      // Check if the element is found and return the href value
      if (element != null) {
        String hrefValue = element.attributes['href'] ?? '';
        String nextLink = "https://tasty.co" + hrefValue;
        print("nextLinkRandom: " + nextLink);
        return nextLink;
      } else {
        print("No link found.");
        randVid();
        return "No link found.";
      }
    } else {
      print("Failed to fetch the page.");
      return "Failed to fetch the page.";
    }
  }

  String randIndex() {
    Random random = Random();
    int randomIndex = random.nextInt(importantTags.length);
    return importantTags[randomIndex];
  }

  String randSim() {
    Random random = Random();
    int randomIndex = random.nextInt(selectedTags.length);
    return selectedTags[randomIndex];
  }

  Future<String> simVid() async {
    // Logic for simVid button
    Random random = Random();
    int randomIndex = random.nextInt(2);
    String similarVid = "";
    if (randomIndex == 1) {
      similarVid = "https://tasty.co/search?q=" +
          randSim() +
          "+" +
          randSim() +
          "&sort=popular";
      //print(simVid);
    } else {
      similarVid = "https://tasty.co/search?q=" +
          randSim() +
          "+" +
          randIndex() +
          "&sort=popular";
      //print(simVid);
    }
    var response = await http.get(Uri.parse(similarVid));
    if (response.statusCode == 200) {
      var document = parse(response.body);

      // Extract the link using the CSS selector
      var element = document.querySelector("#search-results-feed li a");
      // Check if the element is found and return the href value
      if (element != null) {
        String hrefValue = element.attributes['href'] ?? '';
        String nextLink = "https://tasty.co" + hrefValue;
        print("nextLinkSimilar: " + nextLink);
        return nextLink;
      } else {
        print("No link found.");
        randVid();
        return "No link found.";
      }
    } else {
      print("Failed to fetch the page.");
      return "Failed to fetch the page.";
    }
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
                Text('Tags: ${appState.prettyPrintTags ?? "no tags found"}'),
                const SizedBox(height: 10),
                Text('Next Link: ${appState.nextLink ?? "No next link found"}'),
                const SizedBox(height: 10),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
