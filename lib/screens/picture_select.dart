import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SelectPicturesScreen extends StatefulWidget {
  final Map<String, List<String>> imageMap;
  final String searchQuery;

  const SelectPicturesScreen(
      {super.key, required this.imageMap, required this.searchQuery});

  @override
  State<SelectPicturesScreen> createState() => _SelectPicturesScreenState();
}

class _SelectPicturesScreenState extends State<SelectPicturesScreen> {
  late ScrollController _scrollController;
  List<String> selectedImages = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void handleSelect(String itemName, String imgLink) {
    if (selectedImages.contains(imgLink)) {
      print("Removing: $itemName : $imgLink from selection list");
      selectedImages.remove(imgLink);
    } else {
      print("Adding: $itemName : $imgLink to selection list");
      selectedImages.add(imgLink);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, selectedImages);
          return false; // Prevent the default back navigation
        },
        child: Scaffold(
            backgroundColor: Colors.white12,
            appBar: AppBar(
                title: Text("Scraped images for:\t\t${widget.searchQuery}"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.check, size: 35),
                    onPressed: () => Navigator.pop(context, selectedImages),
                  )
                ]),
            // Default scrolling speed on desktop is rather low
            body: Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  // Only allow scrolling if not at the top or bottom
                  if (_scrollController.position.pixels > 0 &&
                      _scrollController.position.pixels <
                          _scrollController.position.maxScrollExtent) {
                    _scrollController.jumpTo(
                      _scrollController.position.pixels +
                          event.scrollDelta.dy * 2,
                    );
                  }
                }
              },
              child: widget.imageMap.isEmpty
                  ? const Center(child: Text("No results"))
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: widget.imageMap.length,
                      itemBuilder: (context, index) {
                        String itemName = widget.imageMap.keys.elementAt(index);
                        List<String> imageUrls = widget.imageMap[itemName]!;
                        return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              color: Colors.black,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    itemName,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  // Using GridView
                                  GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 10,
                                    ),
                                    itemCount: imageUrls.length,
                                    itemBuilder: (context, imgIndex) {
                                      return Container(
                                          color: Colors.white10,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Image.network(
                                                imageUrls[imgIndex],
                                                fit: BoxFit.contain,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  return loadingProgress == null
                                                      ? child
                                                      : const Center(
                                                          child:
                                                              CircularProgressIndicator());
                                                },
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const Center(
                                                      child: Text(
                                                          "Failed to load image"));
                                                },
                                              ),
                                              Positioned(
                                                top: 8,
                                                left: 8,
                                                child: FloatingActionButton(
                                                    heroTag:
                                                        "select-${imageUrls[imgIndex]}",
                                                    child: Icon(
                                                        selectedImages.contains(
                                                                imageUrls[
                                                                    imgIndex])
                                                            ? Icons.check_box
                                                            : Icons
                                                                .check_box_outline_blank,
                                                        size: 30),
                                                    onPressed: () =>
                                                        handleSelect(
                                                            itemName,
                                                            imageUrls[
                                                                imgIndex])),
                                              )
                                            ],
                                          ));
                                    },
                                  ),
                                ],
                              ),
                            ));
                      },
                    ),
            )));
  }
}
