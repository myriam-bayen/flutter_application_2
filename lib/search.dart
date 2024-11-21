import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:provider/provider.dart';
import 'package:flutter_application_2/main.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String userSearch = ''; // Variable to hold the user's search input
  String searchString = '';
  String nextLink = '';
  String title = '';

  void assembleSearchString() {
    searchString = userSearch;
    List<String> searchList =
        searchString.split(''); // Convert string to list of characters

    for (int i = 0; i < searchList.length; i++) {
      if (searchList[i] == " ") {
        searchList[i] = "+"; // Replace space with '+'
      }
    }

    searchString = "https://tasty.co/search?q=" + searchList.join('');
    print(searchString);
    requestPage();
  }

  void requestPage() async {
    final response = await http.get(Uri.parse(searchString));
    if (response.statusCode == 200) {
      var document = parse(response.body);
      // Extract the link using the CSS selector
      var element = document.querySelector("#search-results-feed li a");
      // Check if the element is found and return the href value
      if (element != null) {
        String hrefValue = element.attributes['href'] ?? '';
        nextLink = "https://tasty.co" + hrefValue;
      }
      print(nextLink);
      newPageTitle();
    }
  }

  void newPageTitle() async {
    final recipe = await http.get(Uri.parse(nextLink));
    if (recipe.statusCode == 200) {
      var document2 = parse(recipe.body);
      var titleElement = document2.querySelector('meta[property="og:title"]');
      if (titleElement != null) {
        setState(() {
          title = titleElement.attributes['content'] ??
              ''; // Update the title state variable
        });
      }
    }
    print(title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Route'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  userSearch = value; // Update userSearch variable
                });
              },
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: assembleSearchString, // Call the function when pressed
              child: const Text('Search!'),
            ),
            if (nextLink.isNotEmpty)
              SizedBox(height: 20), // Add space between buttons
            if (nextLink.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  // Check if the URL is valid and launch it
                  if (nextLink != null &&
                      Uri.tryParse(nextLink)?.hasScheme == true) {
                    final Uri uri = Uri.parse(nextLink);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      // Handle the error or show a message
                      print('Could not launch $nextLink');
                    }
                  } else {
                    // Handle invalid URL
                    print('Invalid URL: $nextLink');
                  }
                },
                child: Text(title.isNotEmpty ? title : 'Loading...'),
              ),
            //Text( 'You searched for: $userSearch'), // Displaying the search input
          ],
        ),
      ),
    );
  }
}
