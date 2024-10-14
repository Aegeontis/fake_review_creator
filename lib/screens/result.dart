import 'package:fake_review_creator/screens/llm_settings.dart';
import 'package:flutter/material.dart';

import '/backend/image_processor.dart';
import '/screens/picture_select.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, List<String>>? imageMap;
  late String? llmResponse;
  final String query;

  ResultScreen(
      {super.key,
      required this.imageMap,
      required this.llmResponse,
      required this.query});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<String>? displayedImages = [];

  @override
  void initState() {
    super.initState();
    // create a list of first 3 links from the imageMap
    if (widget.imageMap != null) {
      for (var images in widget.imageMap!.values) {
        displayedImages!.addAll(images.take(3 - displayedImages!.length));
        if (displayedImages!.length >= 3) break;
      }
    } else {
      print("imageMap is null");
      displayedImages = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.primary),
          title: Center(
              // Capitalize the first letter of the query
              child: Text(
                  widget.query[0].toUpperCase() + widget.query.substring(1),
                  style: Theme.of(context).textTheme.headlineLarge)),
        ),
        body: SafeArea(
          // show 3 pictures from the ebay picture map
          child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                displayedImages == null
                    ? Text("No images found")
                    : Text("Images from ebay",
                        style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 10),
                displayedImages != null
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        child: Padding(
                            padding: EdgeInsets.all(10),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: displayedImages!.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(displayedImages![index],
                                      fit: BoxFit.cover),
                                );
                              },
                            )))
                    : const SizedBox(),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(children: [
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                        onPressed: () {
                          downloadImages(widget.query, displayedImages!);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(7),
                          child: Text("Download images",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                        onPressed: () {
                          checkImages(displayedImages!);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(7),
                          child: Text("Check images",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                        onPressed: () async {
                          displayedImages = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectPicturesScreen(
                                imageMap: widget.imageMap!,
                                searchQuery: widget.query,
                              ),
                            ),
                          );
                          setState(() {});
                        },
                        child: Padding(
                            padding: EdgeInsets.all(7),
                            child: Row(children: [
                              Text("Select different images",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          fontWeight: FontWeight.bold)),
                              const SizedBox(width: 5),
                              Icon(Icons.arrow_forward,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  size: 35)
                            ])),
                      )
                    ])),
                const SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("LLM response",
                      style: Theme.of(context).textTheme.headlineMedium),
                ),
                Row(children: [
                  const Spacer(),
                  IconButton(
                      onPressed: () {
                        widget.llmResponse = "";
                      },
                      icon: Icon(Icons.refresh)),
                  IconButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LLMSettingsScreen())),
                      icon: Icon(Icons.settings, size: 30)),
                  // TODO: Add copy implementation
                  IconButton(onPressed: null, icon: Icon(Icons.copy, size: 30)),
                ]),
                Expanded(
                    child: TextFormField(
                        readOnly: true,
                        maxLines: null,
                        expands: true,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontWeight: FontWeight.bold),
                        // Set text color to red
                        textAlignVertical: TextAlignVertical.top,
                        initialValue: widget.llmResponse,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.secondary,
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white), // Set border color
                          ),
                        )))
              ])),
        ));
  }
}
