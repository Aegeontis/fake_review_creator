import 'package:flutter/material.dart';

import '/screens/amazon_settings.dart';
import '/screens/ebay_settings.dart';
import '/screens/llm_settings.dart';
import '/screens/query.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final FocusNode _focusNode = FocusNode();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Request focus
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text("Query:", style: TextStyle(fontSize: 15)),
                        const SizedBox(width: 15),
                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.only(bottom: -12),
                                    hintText: "e.g. iphone 16 pro",
                                  ),
                                  focusNode: _focusNode,
                                  onFieldSubmitted: (_) => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => QueryScreen(
                                            searchQuery: searchQuery)),
                                  ),
                                  onChanged: (value) =>
                                      setState(() => searchQuery = value),
                                ))),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              )),
                          onPressed: searchQuery == ""
                              ? null
                              : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QueryScreen(
                                          searchQuery: searchQuery))),
                          child: Text(
                              searchQuery == ""
                                  ? "Missing search query"
                                  : "Search",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .fontSize)),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onSecondary,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          minimumSize: const Size(130, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EbaySettingsScreen()))
                          .then((_) => _focusNode.requestFocus()),
                      child: Text("Open ebay image scraper settings",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .fontSize)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onSecondary,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          minimumSize: const Size(130, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AmazonSettingsScreen()))
                          .then((_) => _focusNode.requestFocus()),
                      child: Text("Open amazon review scraper settings",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .fontSize)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onSecondary,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          minimumSize: const Size(130, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const LLMSettingsScreen()))
                          .then((_) => _focusNode.requestFocus()),
                      child: Text("Open LLM settings",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .fontSize)),
                    ),
                  ],
                )))));
  }
}
