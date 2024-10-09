import 'dart:io';
import 'dart:isolate';

import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import "package:http/http.dart" as http;

Future<List<String>> getAmazonQueryResults(
    String query, Map<String, dynamic> amazonSettings) async {
  final receivePort = ReceivePort();
  final isolate =
      await Isolate.spawn(isolateGetAmazonQueryResults, receivePort.sendPort);
  final SendPort sendPort = await receivePort.first as SendPort;

  final resultsPort = ReceivePort();
  sendPort.send([resultsPort.sendPort, query, amazonSettings]);

  final List<String> resultIDs = await resultsPort.first as List<String>;

  if (resultIDs.isEmpty) {
    throw Exception("Amazon Query: No results found");
  } else if (resultIDs[0] == "Exception in isolate") {
    throw Exception(resultIDs[1]);
  }

  receivePort.close();
  isolate.kill(priority: Isolate.immediate);
  return resultIDs;
}

Future<void> isolateGetAmazonQueryResults(SendPort sendPort) async {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  final message = await receivePort.first as List;
  final SendPort resultsPort = message[0] as SendPort;
  final String query = message[1] as String;
  final Map<String, dynamic> amazonSettings =
      message[2] as Map<String, dynamic>;

  try {
    // make sure the country code is entered properly
    String domainSuffix = amazonSettings["domainSuffix"];
    if (!domainSuffix.contains("https://www.amazon.")) {
      domainSuffix = domainSuffix.split("https://www.amazon.").last;
    }
    // same for http
    if (!domainSuffix.contains("http://www.amazon.")) {
      domainSuffix = domainSuffix.split("http://www.amazon.").last;
    }
    if (domainSuffix.contains("amazon.")) {
      domainSuffix = domainSuffix.split("amazon.").last;
    }
    if (!domainSuffix.contains("/")) {
      domainSuffix = domainSuffix.split("/").last;
    }
    // Check if country code is valid
    try {
      http.Response countryCodeResponse =
          await http.get(Uri.parse("https://www.amazon.$domainSuffix"));
      if (countryCodeResponse.statusCode != 200) {
        throw Exception("Amazon Query: INVALID COUNTRY CODE: $domainSuffix");
      }
    } catch (e) {
      throw Exception("Amazon Query: INVALID COUNTRY CODE: $domainSuffix");
    }

    Document rawDocument;
    try {
      String requestString = "https://www.amazon.$domainSuffix/s?k=$query";
      print("Amazon query: Requesting: ${Uri.encodeFull(requestString)}");
      // TODO: Custom user agent
      http.Response response =
          await http.get(Uri.parse(requestString), headers: {
        "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; rv:130.0) Gecko/20100101 Firefox/130.0",
      });
      if (response.statusCode == 200) {
        rawDocument = parse(response.body);
      } else {
        throw Exception(
            "Amazon Query: Failed to download $requestString: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(
          "Amazon Query: Failed to download webpage from amazon.$domainSuffix: ${e.toString()}");
    }

    // Start parsing to get a list of item ids
    List<String> itemIds = [];
    List<Element>? searchResults = rawDocument
        .querySelectorAll('div[data-component-type="s-search-result"]');
    if (searchResults.isEmpty) {
      throw Exception(
          "Amazon Query: No search results found or failed to parse");
    }
    for (Element element in searchResults) {
      try {
        String? href = element.querySelector("[href]")?.attributes["href"];
        if (href != null) {
          if (href.contains("/dp/")) {
            String hrefSplit = href.split("/ref=").first.split("/dp/").last;
            print("Amazon query: $hrefSplit");
            itemIds.add(hrefSplit);
          }
        }
      } catch (e) {
        print("Amazon query: Failed to parse item list");
      }
    }
    print("Amazon query: Found ${itemIds.length} items");
    resultsPort.send(itemIds);
  } catch (e) {
    resultsPort.send(["Exception in isolate", e.toString()]);
  }
}

/// Return a map of results from the first item of the List that has reviews
Future<List<String>> getAmazonReviewsList(
    Map<String, dynamic> amazonSettings, List<String> itemIDs) async {
  final receivePort = ReceivePort();
  final isolate =
      await Isolate.spawn(isolateGetAmazonReviews, receivePort.sendPort);
  final SendPort sendPort = await receivePort.first as SendPort;

  final resultsPort = ReceivePort();
  sendPort.send([resultsPort.sendPort, amazonSettings, itemIDs]);

  final List<String> reviewsList = await resultsPort.first as List<String>;

  if (reviewsList.isEmpty) {
    throw Exception("Amazon reviews: No results found");
  } else if (reviewsList[0] == "Exception in isolate") {
    throw Exception(reviewsList[1]);
  }

  receivePort.close();
  isolate.kill(priority: Isolate.immediate);
  return reviewsList;
}

Future<void> isolateGetAmazonReviews(SendPort sendPort) async {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  final message = await receivePort.first as List;
  final SendPort resultsPort = message[0] as SendPort;
  final Map<String, dynamic> amazonSettings =
      message[1] as Map<String, dynamic>;
  final List<String> itemIDs = message[2] as List<String>;

  List<String> reviews = [];
  Document rawDocument;

  try {
    for (String itemID in itemIDs) {
      print("Amazon reviews: Processing: $itemID");
      for (String starType in [
        "five_star",
        "four_star",
        "three_star",
        "two_star",
        "one_star"
      ]) {
        print("Amazon reviews: Processing $starType for: $itemID");
        // cycle through all pages
        int pageNumber = 0;
        while (true) {
          if (reviews.length >= amazonSettings["reviewsAmount"]) {
            print("Amazon reviews: Found ${reviews.length} reviews. Stopping");
            resultsPort.send(reviews);
            return;
          }

          String requestString =
              "https://www.amazon.${amazonSettings["domainSuffix"]}/product-reviews/$itemID/"
              "?pageNumber=$pageNumber"
              "&filterByStar=$starType"
              "&sortBy=${amazonSettings["sortByRecent"] ? "recent" : "helpful"}";
          print("Amazon reviews: Requesting: ${Uri.encodeFull(requestString)}");
          try {
            // Not sure if all of the headers are necessary, but a user-agent alone doesn't suffice
            http.Response response = await http.get(
              Uri.parse(requestString),
              headers: {
                "User-Agent":
                    "Mozilla/5.0 (Windows NT 10.0; rv:130.0) Gecko/20100101 Firefox/130.0",
                "accept":
                    "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
                "accept-language": "en-US,en;q=0.9",
                "priority": "u=0, i",
                "sec-fetch-dest": "document",
                "sec-fetch-mode": "navigate",
                "sec-fetch-site": "none",
                "sec-fetch-user": "?1",
                "upgrade-insecure-requests": "1",
              },
            );
            if (response.statusCode == 200) {
              rawDocument = parse(response.body);
            } else {
              throw Exception(
                  "Amazon reviews: Failed to download $requestString: ${response.statusCode}");
            }
          } catch (e) {
            throw Exception(
                "Amazon reviews: Failed to download $requestString: ${e.toString()}");
          }

          if (rawDocument.outerHtml.toLowerCase().contains("captcha")) {
            throw Exception("Amazon reviews: Triggered captcha");
          } else if (rawDocument.outerHtml
              .toLowerCase()
              .contains('id="ap-other-signin-issues-link"')) {
            throw Exception("Amazon reviews: Triggered login");
          }

          Element? reviewsEndMessage =
              rawDocument.querySelector('div[class\$="no-reviews-section"]');

          if (reviewsEndMessage != null) {
            print(
                "Amazon reviews: Reached last page for $starType reviews for $itemID");
            pageNumber = 0;
            break;
          }

          Element? reviewsList =
              rawDocument.querySelector("#cm_cr-review_list");

          if (reviewsList == null) {
            throw Exception("Amazon reviews: Failed to find review list");
          } else if (reviewsList.children.isEmpty) {
            print("Amazon reviews: No $starType reviews found for $itemID");
          } else {
            for (Element review in reviewsList
                .querySelectorAll('span[data-hook="review-body"]')) {
              if (review.children.isEmpty) {
                print(
                    "Amazon reviews: Review body empty, skipping: ${review.text}");
                continue;
              }

              Element? reviewBody = review.children.first;
              if (reviewBody.className == "cr-original-review-content" &&
                  amazonSettings["ignoreForeignReviews"]) {
                print(
                    "Amazon reviews: Found foreign review, skipping: ${reviewBody.text}");
              } else {
                if (reviewBody.text.isNotEmpty && reviewBody.text.length > 25) {
                  // Print truncated
                  print(
                      "Amazon reviews: Adding review: ${reviewBody.text.substring(0, 25)}...");
                  reviews.add(reviewBody.text);
                } else {
                  print(
                      "Amazon reviews: Review too short or non-existent, skipping: ${reviewBody.text}");
                }
              }
            }
          }
          pageNumber++;
          // avoid overloading amazon
          sleep(const Duration(seconds: 2));
        }
      }
    }
  } catch (e) {
    resultsPort.send(["Exception in isolate", e.toString()]);
  }
}
