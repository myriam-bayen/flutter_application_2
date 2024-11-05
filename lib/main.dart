import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
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
    'oven-baked',
    'pan-fried',
    'deep-fried',
    'deep-fry',
    'baking',
    'baked',
    'bakery_goods',
    'desserts',
    'breakfast',
    'snacks',
    'low_calore',
    'gluten',
    'low_sugar',
    'grilled',
    'smoked',
    'sous-vide',
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
    randVid();
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  Future<void> fetchPageSource(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        extractInformation(response.body);
      } else {
        print("Failed to fetch the page. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // Catching generic exceptions including redirect issues
      print("An error occurred while fetching the page: $e");
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
        print("VIDELOINK!!");
        print(videoLink);
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
          print("ORIGINAL TAGS");
          for (String c in tags) {
            print(c);
          }
        }
      }
      notifyListeners();
    }

    selectedTags =
        tags.where((tag) => importantTags.contains(tag.toLowerCase())).toList();
    print("NEW TAGS");
    for (String c in selectedTags) {
      print(c);
    }

    // Format the selected tags
    formattedSelectedTags = selectedTags.join('+');
    prettyPrintTags = selectedTags.join(', ');

    // Ensure the UI updates
    notifyListeners();
  }

  randVid() async {
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
        fetchPageSource(nextLink);
        print("nextLinkRandom: " + nextLink);
      } else {
        print("No link found.");
        randVid();
      }
    } else {
      print("Failed to fetch the page.");
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

  simVid() async {
    // Logic for simVid button
    Random random = Random();
    int randomIndex = random.nextInt(selectedTags.length);
    String similarTag = selectedTags[randomIndex];
    selectedTags.removeAt(randomIndex);

    String similarVid = "https://tasty.co/search?q=$similarTag&sort=popular";
    print(similarVid);

    var response = await http.get(Uri.parse(similarVid));
    if (response.statusCode == 200) {
      var document = parse(response.body);
      var element = document.querySelector("#search-results-feed li a");
      if (element != null) {
        String hrefValue = element.attributes['href'] ?? '';
        String nextLink = "https://tasty.co$hrefValue";
        if (watched_vids.contains(nextLink)) {
          simVid();
        }
        watched_vids.add(nextLink);
        fetchPageSource(nextLink);
      } else {
        print("No link found.");
      }
    } else {
      print("Failed to fetch the page.");
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
    // Initialize video after the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideo();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _initializeVideo() {
    if (!mounted) return;

    final appState = Provider.of<MyAppState>(context, listen: false);
    if (appState.videoLink != null && appState.videoLink!.isNotEmpty) {
      setState(() {
        _controller?.dispose();
        _controller = VideoPlayerController.network(appState.videoLink!)
          ..setLooping(true);
        _initializeVideoPlayerFuture = _controller!.initialize();
      });
    }
  }

  Future<void> handleNextSimVid() async {
    if (!mounted) return;

    final appState = Provider.of<MyAppState>(context, listen: false);
    appState.simVid();
  }

  Future<void> handleNextRandVid() async {
    if (!mounted) return;

    final appState = Provider.of<MyAppState>(context, listen: false);
    appState.randVid();
    _initializeVideo();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Tinder for Food'),
      ),
      body: Center(
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
                Text(
                  appState.prettyPrintTags ?? '',
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: handleNextSimVid,
                child: Text('Next Sim Vid'),
              ),
              ElevatedButton(
                onPressed: handleNextRandVid,
                child: Text('Next Rand Vid'),
              ),
              if (_initializeVideoPlayerFuture != null) ...[
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
                FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  //HERE WE NEED TO CALL THE HANDLRANDNEXTVID Automatically so that it displays the video and like sets it up straightaway
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
