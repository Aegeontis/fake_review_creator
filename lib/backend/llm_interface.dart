import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;

/// Return a map of results from the first item of the List that has reviews
Future<String> queryLLM(Map<String, dynamic> llmSettings, List<String> reviews,
    String query) async {
  final receivePort = ReceivePort();
  Future<void> Function(SendPort)? isolateInterface;
  switch (llmSettings["instanceType"]) {
    case "custom type":
      print("Custom type selected, returning system prompt + user prompt + reviews");
      // Return prompt to be just printed to user
      return "${llmSettings["systemPrompt"]}"
          "\n\n\n\n"
          "${llmSettings["userPrompt"].replaceFirst("[PRODUCT_NAME]", query)}"
          "\n\n"
          "$reviews";
    case "openRouter":
      isolateInterface = isolateQueryOpenRouter;
      if (llmSettings["accessKey"] == "") {
        throw Exception("Please set access api key in LLM settings");
      }
      break;
    default:
      throw Exception(
          "Invalid LLM instance type: ${llmSettings["instanceType"]}");
  }
  final isolate = await Isolate.spawn(isolateInterface, receivePort.sendPort);
  final SendPort sendPort = await receivePort.first as SendPort;

  final resultsPort = ReceivePort();
  sendPort.send([resultsPort.sendPort, llmSettings, reviews, query]);

  final String response = await resultsPort.first as String;

  if (response.isEmpty) {
    throw Exception("LLM Response: No response?");
  } else if (response.startsWith("Exception in isolate")) {
    throw Exception(response);
  }

  receivePort.close();
  isolate.kill(priority: Isolate.immediate);
  return response;
}

Future<void> isolateQueryOpenRouter(SendPort sendPort) async {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  final message = await receivePort.first as List;
  final SendPort resultsPort = message[0] as SendPort;
  final Map<String, dynamic> llmSettings = message[1] as Map<String, dynamic>;
  final List<String> reviews = message[2] as List<String>;
  final String query = message[3] as String;

  try {
    http.Response response = await http.post(
      Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer ${llmSettings["accessKey"]}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": llmSettings["modelName"],
        "max_tokens": llmSettings["tokenSize"],
        "messages": [
          {"role": "system", "content": llmSettings["systemPrompt"]},
          {
            "role": "user",
            "content": "${llmSettings["userPrompt"].replaceFirst("[PRODUCT_NAME]", query)}\n\n$reviews"
          }
        ]
      }),
    );

    // Handle the response
    if (response.statusCode == 200) {
      Map<String, dynamic> responseMap = jsonDecode(response.body);
      String resultBody =
          responseMap["choices"][0]["message"]["content"].trim();
      if (resultBody.isNotEmpty) {
        // fix some special chars
        resultBody = resultBody
            .replaceAll("Ã¶", "ö")
            .replaceAll("Ã¼", "ü")
            .replaceAll("Ã¼", "ä")
            .replaceAll("Ã¤", "ä");
        resultsPort.send(resultBody);
      } else {
        throw Exception("LLM Response: Response didn't include LLM answer");
      }
    } else {
      throw Exception(
          "LLM Response: Failed to get response: ${response.statusCode}");
    }
  } catch (e) {
    resultsPort.send("Exception in isolate: ${e.toString()}");
  }
}
