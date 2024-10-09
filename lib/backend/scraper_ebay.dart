import 'dart:isolate';

import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import "package:http/http.dart" as http;

Future<List<String>> getEbayQueryResults(
    String query, Map<String, dynamic> ebaySettings) async {
  final receivePort = ReceivePort();
  final isolate =
      await Isolate.spawn(isolateGetEbayQueryResults, receivePort.sendPort);
  final SendPort sendPort = await receivePort.first as SendPort;

  final resultsPort = ReceivePort();
  sendPort.send([resultsPort.sendPort, query, ebaySettings]);

  final List<String> resultIDs = await resultsPort.first as List<String>;

  if (resultIDs.isEmpty) {
    throw Exception("Ebay query: No results found");
  } else if (resultIDs[0] == "Exception in isolate") {
    throw Exception(resultIDs[1]);
  }

  receivePort.close();
  isolate.kill(priority: Isolate.immediate);
  return resultIDs;
}

Future<void> isolateGetEbayQueryResults(SendPort sendPort) async {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  final message = await receivePort.first as List;
  final SendPort resultsPort = message[0] as SendPort;
  final String query = message[1] as String;
  final Map<String, dynamic> ebaySettings = message[2] as Map<String, dynamic>;

  try {
    String conditionsString = "${ebaySettings["conditionNew"] ? "1000|" : ""}"
        "${ebaySettings["conditionOpenbox"] ? "1500|" : ""}"
        "${ebaySettings["conditionRefurbishedCertified"] ? "2000|" : ""}"
        "${ebaySettings["conditionRefurbishedExcellent"] ? "2010|" : ""}"
        "${ebaySettings["conditionRefurbishedVeryGood"] ? "2020|" : ""}"
        "${ebaySettings["conditionRefurbishedGood"] ? "2030|" : ""}"
        "${ebaySettings["conditionUsed"] ? "3000|" : ""}"
        "${ebaySettings["conditionBroken"] ? "7000|" : ""}"
        "${ebaySettings["conditionUnspecified"] ? "10" : ""}";

    if (conditionsString.endsWith("|")) {
      conditionsString =
          conditionsString.substring(0, conditionsString.length - 1);
    }

    // make sure the country code is entered properly
    String domainSuffix = ebaySettings["domainSuffix"];
    if (!domainSuffix.contains("https://www.ebay.")) {
      domainSuffix = domainSuffix.split("https://www.ebay.").last;
    }
    // same for http
    if (!domainSuffix.contains("http://www.ebay.")) {
      domainSuffix = domainSuffix.split("http://www.ebay.").last;
    }
    if (domainSuffix.contains("ebay.")) {
      domainSuffix = domainSuffix.split("ebay.").last;
    }
    if (!domainSuffix.contains("/")) {
      domainSuffix = domainSuffix.split("/").last;
    }
    // Check if country code is valid
    try {
      http.Response countryCodeResponse =
          await http.get(Uri.parse("https://www.ebay.$domainSuffix"));
      if (countryCodeResponse.statusCode != 200) {
        throw Exception("Ebay query: INVALID COUNTRY CODE: $domainSuffix");
      }
    } catch (e) {
      throw Exception("Ebay query: INVALID COUNTRY CODE: $domainSuffix");
    }

    Document rawDocument;
    try {
      String requestString =
          "https://www.ebay.$domainSuffix/sch/i.html?_nkw=$query"
          "&LH_SellerType=${ebaySettings["sellerType"]}"
          "&LH_Complete=${ebaySettings["showCompleted"] ? "1" : "0"}"
          "&LH_Sold=${ebaySettings["showSold"] ? "1" : "0"}"
          "&LH_ItemCondition=$conditionsString"
          "&_pgn=${ebaySettings["lastPage"] ? "100" : "1"}"
          "&ipg=${ebaySettings["resultsAmount"]}";
      print("Ebay query: Requesting: ${Uri.encodeFull(requestString)}");
      http.Response response = await http.get(Uri.parse(requestString));
      if (response.statusCode == 200) {
        rawDocument = parse(response.body);
      } else {
        throw Exception(
            "Ebay query: Failed to download $requestString: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(
          "Ebay query: Failed to download webpage from ebay.$domainSuffix: ${e.toString()}");
    }

    // Start parsing to get a list of item ids
    List<String> itemIds = [];
    List<Element>? searchResults =
        rawDocument.querySelector("#srp-river-results")?.children[0].children;
    if (searchResults == null) {
      throw Exception("Ebay query: No search results found or failed to parse");
    }
    for (Element element in searchResults) {
      // get the link
      try {
        String? href = element.querySelector("a")?.attributes["href"];
        // not all elements are items in this list
        if (href != null) {
          // remove base url and split by /
          List<String> splitHref = href.split("https://")[1].split("/");
          if (splitHref[1] == "itm") {
            // Remove tracking after id
            String itemId = splitHref[2].split("?_").first;
            itemIds.add(itemId);
          }
        }
      } catch (e) {
        print("Ebay query: Failed to parse item list");
      }
    }
    print("Ebay query: Found ${itemIds.length} items");

    resultsPort.send(itemIds);
  } catch (e) {
    resultsPort.send(["Exception in isolate", e.toString()]);
  }
}

Future<Map<String, List<String>>> getEbayImagesMap(
    String domainSuffix, List<String> itemIDs) async {
  final receivePort = ReceivePort();
  final isolate =
      await Isolate.spawn(isolateGetEbayImagesMap, receivePort.sendPort);
  final SendPort sendPort = await receivePort.first as SendPort;

  final resultsPort = ReceivePort();
  sendPort.send([resultsPort.sendPort, itemIDs, domainSuffix]);

  final Map<String, List<String>> imagesMap =
      await resultsPort.first as Map<String, List<String>>;

  if (imagesMap.isEmpty) {
    throw Exception("Ebay image scraper: No results found");
  } else if (imagesMap.containsKey("Exception in isolate")) {
    throw Exception(imagesMap["Exception in isolate"]![0]);
  }

  receivePort.close();
  isolate.kill(priority: Isolate.immediate);
  return imagesMap;
}

Future<void> isolateGetEbayImagesMap(SendPort sendPort) async {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  final message = await receivePort.first as List;
  final SendPort resultsPort = message[0] as SendPort;
  final List<String> itemIDs = message[1] as List<String>;
  final String domainSuffix = message[2] as String;

  try {
    Map<String, List<String>> picturesMap = {};

    // Start all the requests in parallel
    List<Future<void>> futures = itemIDs.map((String itemID) async {
      Document rawDocument;
      try {
        String requestString = "https://www.ebay.$domainSuffix/itm/$itemID";
        print(
            "Ebay image scraper: Requesting: ${Uri.encodeFull(requestString)}");
        http.Response response = await http.get(Uri.parse(requestString));
        if (response.statusCode == 200) {
          rawDocument = parse(response.body);
        } else {
          print(
              "Ebay image scraper: Failed to download $requestString: ${response.statusCode}");
          return [];
        }
      } catch (e) {
        print(
            "Ebay image scraper: Failed to download webpage from ebay.$domainSuffix: ${e.toString()}");
        return [];
      }

      // Get listing name
      String? realName = rawDocument
          .querySelector('meta[name="twitter:title"]')
          ?.attributes["content"];

      List<String> imageSources = [];
      for (Element element in rawDocument.querySelectorAll("[data-zoom-src]")) {
        String? src = element.attributes["data-zoom-src"];
        if (src != null) {
          imageSources.add(src);
        }
      }

      // deduplicate
      imageSources = imageSources.toSet().toList();

      if (imageSources.isNotEmpty) {
        picturesMap["${realName ?? "Unknown name"} (id: $itemID)"] =
            imageSources;
      }

      print("Ebay image scraper: Finished $itemID");
    }).toList();

    // Wait for all requests and parses to finish
    await Future.wait(futures);

    print(
        "Ebay image scraper: Finished all requests with ${picturesMap.length} results");
    resultsPort.send(picturesMap);
  } catch (e) {
    resultsPort.send({
      "Exception in isolate": [e.toString()]
    });
  }
}
