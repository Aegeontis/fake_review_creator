import 'package:flutter/material.dart';

import '/backend/llm_interface.dart';
import '/backend/scraper_amazon.dart';
import '/backend/scraper_ebay.dart';
import '/backend/settings_manager.dart';
import '/screens/result.dart';

class QueryScreen extends StatefulWidget {
  final String searchQuery;

  const QueryScreen({super.key, required this.searchQuery});

  @override
  State<QueryScreen> createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {
  String parsingEbayQuery = "waiting";
  String scrapingEbayImages = "waiting";
  Map<String, List<String>>? ebayImageMap;
  String parsingAmazonQuery = "waiting";
  String scrapingAmazonReviews = "waiting";
  String queryingLLM = "waiting";
  String? llmResponse;

  @override
  void initState() {
    super.initState();
    startQueries();
  }

  void startQueries() async {
    setState(() {
      parsingEbayQuery = "loading";
      parsingAmazonQuery = "loading";
    });

    final Map<String, dynamic> ebaySettings = await getEbaySettings();
    final Map<String, dynamic> amazonSettings = await getAmazonSettings();

    // Use Future.wait to run both query blocks concurrently
    await Future.wait([
      // eBay query
      () async {
        try {
          final List<String> resultIDs =
              await getEbayQueryResults(widget.searchQuery, ebaySettings);
          setState(() {
            parsingEbayQuery = "finished";
            scrapingEbayImages = "loading";
          });
          try {
            ebayImageMap =
                await getEbayImagesMap(ebaySettings["domainSuffix"], resultIDs);
            setState(() {
              scrapingEbayImages = "finished";
            });
          } catch (e) {
            displayErrorMessage("scraping images from ebay", e.toString());
            setState(() {
              scrapingEbayImages = "error";
            });
          }
        } catch (e) {
          displayErrorMessage(
              "querying ebay with: ${widget.searchQuery}", e.toString());
          setState(() {
            parsingEbayQuery = "error";
            scrapingEbayImages = "error";
          });
        }
      }(),

      // Amazon query
      () async {
        try {
          final List<String> itemIDs =
              await getAmazonQueryResults(widget.searchQuery, amazonSettings);
          setState(() {
            parsingAmazonQuery = "finished";
            scrapingAmazonReviews = "loading";
          });
          try {
            final List<String> amazonReviewsList =
                await getAmazonReviewsList(amazonSettings, itemIDs);
            setState(() {
              scrapingAmazonReviews = "finished";
              queryingLLM = "loading";
            });
            final Map<String, dynamic> llmSettings = await getLLMSettings();
            try {
              llmResponse = await queryLLM(
                  llmSettings, amazonReviewsList, widget.searchQuery);
              setState(() {
                queryingLLM = "finished";
              });
            } catch (e) {
              displayErrorMessage("querying LLM", e.toString());
              setState(() {
                queryingLLM = "error";
              });
            }
          } catch (e) {
            displayErrorMessage("scraping amazon reviews", e.toString());
            setState(() {
              scrapingAmazonReviews = "error";
            });
          }
        } catch (e) {
          displayErrorMessage(
              "querying amazon with: ${widget.searchQuery}", e.toString());
          setState(() {
            parsingAmazonQuery = "error";
            scrapingAmazonReviews = "error";
          });
        }
      }(),
    ]);

    print("All jobs finished, going to result screen");
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ResultScreen(
          imageMap: ebayImageMap,
          llmResponse: llmResponse,
          query: widget.searchQuery);
    }));
  }

  void displayErrorMessage(String origin, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Error while $origin"),
              content: Text(message),
              actions: <Widget>[
                // TODO: Add stop button
                Center(
                    child: TextButton(
                        child: const Text("Ignore"),
                        onPressed: () {
                          // Close popup
                          Navigator.of(context).pop();
                        })),
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.primary),
          title: Center(
              child: Text("Fake review creator",
                  style: Theme.of(context).textTheme.headlineLarge)),
        ),
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    left: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? MediaQuery.of(context).size.width / 4
                        : 50,
                    right: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? MediaQuery.of(context).size.width / 4
                        : 50),
                child: Center(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(
                                    "Querying ebay with ${widget.searchQuery}",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                        fontWeight: FontWeight.bold)),
                                trailing:
                                    buildStateWidget(parsingEbayQuery, context),
                              ),
                              const SizedBox(height: 5),
                              ListTile(
                                title: Text("Scraping images from ebay",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                        fontWeight: FontWeight.bold)),
                                trailing: buildStateWidget(
                                    scrapingEbayImages, context),
                              ),
                            ])),
                    const SizedBox(height: 10),
                    Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(
                                    "Querying Amazon with ${widget.searchQuery}",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                        fontWeight: FontWeight.bold)),
                                trailing: buildStateWidget(
                                    parsingAmazonQuery, context),
                              ),
                              const SizedBox(height: 5),
                              ListTile(
                                title: Text("Scraping Amazon reviews",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                        fontWeight: FontWeight.bold)),
                                trailing: buildStateWidget(
                                    scrapingAmazonReviews, context),
                              ),
                              const SizedBox(height: 5),
                              ListTile(
                                title: Text("Querying LLM",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                        fontWeight: FontWeight.bold)),
                                trailing:
                                    buildStateWidget(queryingLLM, context),
                              ),
                            ])),
                    const SizedBox(height: 20),
                    Center(
                        child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            // TODO: Implement stopping query
                            onPressed: null,
                            child: Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Text("Stop query",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .headlineSmall!
                                            .fontSize)))))
                  ],
                )))));
  }

  Widget buildStateWidget(String state, BuildContext context) {
    if (state == "waiting") {
      return Icon(Icons.hourglass_top,
          color: Theme.of(context).colorScheme.onSecondary);
    } else if (state == "loading") {
      return CircularProgressIndicator(
          color: Theme.of(context).colorScheme.onSecondary);
    } else if (state == "finished") {
      return Icon(Icons.check,
          size: 40, color: Theme.of(context).colorScheme.onSecondary);
    } else if (state == "error") {
      return Icon(Icons.error,
          size: 40, color: Theme.of(context).colorScheme.error);
    } else {
      return const Text("Unknown state? Report on GitHub");
    }
  }
}
