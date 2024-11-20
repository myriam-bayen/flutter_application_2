import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/saved.dart';
import 'package:flutter_application_2/search.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'dart:convert';
import 'dart:math';
import 'package:video_player/video_player.dart';

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
  List<String?> watched_vids = [];
  String? formattedSelectedTags;
  List<String> importantTags = [
    // Ingredients
    'chicken', 'beef', 'pork', 'lamb', 'turkey', 'fish', 'shrimp', 'salmon',
    'tuna', 'tofu', 'lentils', 'beans', 'chickpeas', 'tomatoes', 'potatoes',
    'mushrooms', 'garlic', 'onion', 'carrots', 'bell peppers', 'spinach',
    'kale', 'broccoli', 'cauliflower', 'pumpkin', 'zucchini', 'sweet potatoes',
    'cheese', 'eggs', 'butter',
    // Dish Types
    'soup', 'stews', 'salad', 'pasta', 'sandwich', 'burger', 'pizza',
    'casserole', 'stir-fry', 'curry', 'roast', 'grilled', 'baked', 'fried',
    'braised', 'sautéed', 'slow-cooked', 'barbecue', 'sushi', 'tacos', 'wraps',
    'quiche', 'pie', 'pastry', 'bread', 'pancakes', 'waffles', 'muffins',
    'cake', 'cookies', 'vegetables',
    // Cuisines
    'italian', 'mexican', 'chinese', 'indian', 'french', 'japanese', 'thai',
    'greek', 'mediterranean', 'middle eastern', 'korean', 'american',
    'southern (u.s.)', 'vietnamese',
    // Cooking Methods
    'oven-baked', 'pan-fried', 'deep-fried', 'grilled', 'smoked', 'sous-vide',
    'air-fried', 'roasted', 'pressure-cooked', 'boiled', 'poached', 'steamed',
    'quick',
    // Dietary Preferences
    'vegetarian', 'vegan', 'gluten-free', 'dairy-free', 'low-carb', 'keto',
    'paleo', 'whole30', 'pescatarian',
    // Themes & Occasions
    'halloween', 'christmas', 'thanksgiving', 'easter', 'summer', 'winter',
    'comfort food', 'game day', 'potluck', 'kid-friendly', 'fall', 'spring',
    'dinner', 'snack', 'jewish', 'comfort_food',
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
    watched_vids.add(url);
    print("watched videos!");
    for (var i = 0; i < watched_vids.length; i++) {
      print(watched_vids[i]);
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      extractInformation(response.body);
    } else {
      print("Failed to fetch the page.");
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
          notifyListeners();
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

    // Format the selected tags
    formattedSelectedTags = selectedTags.join('+');
    prettyPrintTags = selectedTags.join(', ');

    // Ensure the UI updates
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
        for (var i = 0; i < watched_vids.length; i++) {
          if (watched_vids[i] == nextLink) {
            randVid();
          }
        }
        fetchPageSource(nextLink);
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
    selectedTags.remove(randomIndex);
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
          "+" +
          randSim() +
          "&sort=popular";
      print(similarVid);
    } else {
      similarVid = "https://tasty.co/search?q=" +
          randSim() +
          "+" +
          randIndex() +
          "+" +
          randSim() +
          "&sort=popular";
      print(similarVid);
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
        for (var i = 0; i < watched_vids.length; i++) {
          if (watched_vids[i] == nextLink) {
            simVid();
          }
        }
        fetchPageSource(nextLink);
        return nextLink;
      } else {
        print("No link found.");
        simVid();
        return "No link found.";
      }
    } else {
      print("Failed to fetch the page.");
      return "Failed to fetch the page.";
    }
  }
}

// Video Player Section

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl), // Use the passed videoUrl here
    );
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _initializeVideo() {
    final appState = context.read<MyAppState>();

    // Check if there is a video link before initializing
    if (appState.videoLink != null && appState.videoLink!.isNotEmpty) {
      print(
          "Initializing video with URL: ${appState.videoLink}"); // Debug statement
      _controller = VideoPlayerController.network(appState.videoLink!)
        ..setLooping(true);
      _initializeVideoPlayerFuture = _controller!.initialize();
    }
  }

  void _updateVideo() {
    final appState = context.read<MyAppState>(); // Use read instead of watch

    if (_controller?.dataSource != appState.videoLink) {
      setState(() {
        _controller?.dispose(); // Dispose of the previous controller
        _initializeVideo(); // Reinitialize with the new link
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateVideo();

    var appState = context.watch<MyAppState>();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 232, 202, 195),
      appBar: AppBar(
        title: Image.asset(
          'assets/tinder.png', // Path to your image
          width: 350, // Set the width of the image
          height: 88, // Set the height of the image
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            // Swiped right
            context.read<MyAppState>().simVid();
          } else {
            // Swiped left
            context.read<MyAppState>().randVid();
          }
          _updateVideo();
        },
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (appState.pageTitle != null) ...[
                  Text(
                    appState.pageTitle!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                ],
                if (_initializeVideoPlayerFuture != null) ...[
                  FutureBuilder(
                    future: _initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        if (_controller!.value.isPlaying) {
                          _controller!.pause();
                        } else {
                          _controller!.play();
                        }
                      });
                    },
                    child: Icon(
                      _controller!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                  ),
                ],
                SizedBox(height: 16),
                new Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SearchPage()),
                          );
                        },
                        child: Image.asset(
                          'assets/search.png', // Path to your image
                          width: 24, // Set the width of the image
                          height: 24, // Set the height of the image
                        ),
                      ),
                      SizedBox(width: 16), // Add space between buttons
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SavedPage()),
                          );
                        },
                        child: Image.asset(
                          'assets/savedlogo.png', // Path to your image
                          width: 24, // Set the width of the image
                          height: 24, // Set the height of the image
                        ), // Keep text for this button
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
