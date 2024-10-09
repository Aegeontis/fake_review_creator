import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sanitize_filename/sanitize_filename.dart';

/// Checks if provided images can be found on imgur and google images
Future<Map<String, Map<String, bool>>> checkImages(
    List<String> picturesList) async {
  for (String pictureLink in picturesList) {
    http.Response response = await http.post(
      Uri.parse("https://google-reverse-image-api.vercel.app/reverse"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"imageUrl": pictureLink}),
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
    } else {
      throw Exception("Failed to check image: ${response.statusCode}");
    }
  }
  return {};
}

void downloadImages(String searchQuery, List<String> picturesList) async {
  // Get the platforms download dir
  Directory? downloadsDir = await getDownloadsDirectory();
  if (downloadsDir == null) {
    print(
        "Failed to get downloads directory from path_provider. Using hardcoded values");
    switch (Platform.operatingSystem) {
      case "linux":
        downloadsDir = Directory("${Platform.environment["HOME"]}/Downloads");
        print("Linux detected using $downloadsDir");
        break;
      default:
        throw Exception("No preset downloads directory found. Aborting");
    }
  }
  // Sanitize search query to create a folder from it
  String sanitizedFolderName = sanitizeFilename(searchQuery);
  String downloadPath =
      "${downloadsDir.path}/fake_review_creator/$sanitizedFolderName";
  print("Downloading to: $downloadPath");

  // Create subdir
  if (!await Directory(downloadPath).exists()) {
    await Directory(downloadPath).create(recursive: true);
    print("Query subdir created: $downloadPath");
  } else {
    print("Query subdir already exists: $downloadPath");
  }

  // List to hold all download tasks (Futures)
  List<Future<void>> downloadTasks = [];

  for (String pictureLink in picturesList) {
    // Create folder with item id as name
    if (!await Directory(downloadPath).exists()) {
      await Directory(downloadPath).create();
      print("Item subdir created: $downloadPath");
    } else {
      print("Item subdir already exists: $downloadPath");
    }

    // Add the picture download logic to the downloadTasks list
    downloadTasks.add(() async {
      try {
        print("Downloading: ${Uri.encodeFull(pictureLink)}");
        http.Response response = await http.get(Uri.parse(pictureLink));
        await File(
                "$downloadPath/${sanitizeFilename(pictureLink, replacement: "_")}")
            .writeAsBytes(response.bodyBytes);
      } catch (e) {
        print("Failed to download image: $e");
      }
    }());
  }

  // Wait for all download tasks to complete
  await Future.wait(downloadTasks);
}
