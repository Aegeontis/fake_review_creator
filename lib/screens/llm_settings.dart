import 'package:flutter/material.dart';

import '/backend/settings_manager.dart';

class LLMSettingsScreen extends StatefulWidget {
  const LLMSettingsScreen({super.key});

  @override
  State<LLMSettingsScreen> createState() => _LLMSettingsScreenState();
}

class _LLMSettingsScreenState extends State<LLMSettingsScreen> {
  Map<String, dynamic>? llmSettingsMap;
  bool loadingSettings = true;

  @override
  void initState() {
    super.initState();
    getLLMSettings().then((map) => setState(() {
          llmSettingsMap = map;
          setState(() => loadingSettings = false);
        }));
  }

  void showInstanceTypePopup() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Instance type (more coming soon)"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: Text("OpenRouter.ai",
                        style: Theme.of(context).textTheme.bodyLarge),
                    value: llmSettingsMap!["instanceType"] == "openRouter",
                    onChanged: (_) {
                      setState(() {
                        llmSettingsMap!["instanceType"] = "openRouter";
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text("Custom type",
                        style: Theme.of(context).textTheme.bodyLarge),
                    value: llmSettingsMap!["instanceType"] == "custom type",
                    onChanged: (_) {
                      setState(() {
                        llmSettingsMap!["instanceType"] = "custom type";
                      });
                    },
                  )
                ],
              ),
              actions: [
                Center(
                  child: TextButton(
                    child: const Text("Apply"),
                    onPressed: () {
                      setLLMSettings(llmSettingsMap!);
                      Navigator.of(context).pop();
                    },
                  ),
                )
              ],
            );
          },
        );
      },
    );
    // Update so that instance specific settings are shown
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.primary),
          title: Center(
              child: Text("LLM settings",
                  style: Theme.of(context).textTheme.headlineLarge)),
          actions: [
            TextButton(
                onPressed: () async {
                  setState(() {
                    loadingSettings = true;
                  });
                  await setDefaultLLMSettings(forceReset: true);
                  llmSettingsMap = await getLLMSettings();
                  setState(() {
                    loadingSettings = false;
                  });
                },
                child: Text("Reset LLM settings"))
          ],
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
                  child: loadingSettings
                      ? Column(children: [
                          Text(
                              "Loading settings... (this should not take long. Open an issue on github if it does)"),
                          const CircularProgressIndicator()
                        ])
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ListTile(
                              title: const Text("Instance type"),
                              trailing: Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Icon(Icons.arrow_forward)),
                              onTap: () => showInstanceTypePopup(),
                            ),
                            //llmSettingsMap!["instanceType"] != "custom type"
                            //    ? ListTile(
                            //                      title: TextFormField(
                            //                        decoration: InputDecoration(
                            //                          contentPadding:
                            //                              const EdgeInsets.symmetric(
                            //                                vertical: 5),
                            //                          isDense: true,
                            //                        ),
                            //                        initialValue:
                            //                            llmSettingsMap!["instanceAddress"],
                            //                        onChanged: (value) => setState(() =>
                            //                          llmSettingsMap!["instanceAddress"] =
                            //                              value),
                            //                      ),
                            //                      // TODO: Change "default" depending on instance type
                            //                      leading: Text(
                            //                        "LLM instance address (default: http://127.0.0.1:11435):",
                            //                        style: Theme.of(context)
                            //                            .textTheme
                            //                            .bodyLarge),
                            //                    )
                            //                : const SizedBox(),
                            llmSettingsMap!["instanceType"] != "custom type"
                                ? ListTile(
                                    title: TextFormField(
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 5),
                                        isDense: true,
                                      ),
                                      initialValue:
                                          llmSettingsMap!["accessKey"],
                                      onChanged: (value) => setState(() =>
                                          llmSettingsMap!["accessKey"] = value),
                                    ),
                                    leading: Text("Api access key:",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge),
                                  )
                                : const SizedBox(),
                            llmSettingsMap!["instanceType"] != "custom type"
                                ? ListTile(
                                    title: TextFormField(
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 5),
                                        isDense: true,
                                      ),
                                      initialValue: llmSettingsMap!["tokenSize"]
                                          .toString(),
                                      onChanged: (value) => setState(() =>
                                          llmSettingsMap!["tokenSize"] =
                                              value == ""
                                                  ? 260
                                                  : int.tryParse(value) ?? 260),
                                    ),
                                    leading: Text(
                                        "Max token size (default: 260):",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge),
                                  )
                                : const SizedBox(),
                            ListTile(
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // Aligns the items to the top
                                children: [
                                  Text(
                                    "System prompt for the llm: \t\t\t",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    // You can adjust the flex if you want the input field to take more space
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        fillColor: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                        filled: true,
                                        contentPadding:
                                            const EdgeInsets.all(10),
                                        isDense: true,
                                      ),
                                      maxLines: null,
                                      initialValue:
                                          llmSettingsMap!["systemPrompt"],
                                      onChanged: (value) => setState(() =>
                                          llmSettingsMap!["systemPrompt"] =
                                              value),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListTile(
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // Aligns the items to the top
                                children: [
                                  Text(
                                    "User prompt for the llm: \t\t\t\t\t\t\t\t",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    // You can adjust the flex if you want the input field to take more space
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.all(10),
                                        fillColor: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                        filled: true,
                                        isDense: true,
                                      ),
                                      maxLines: null,
                                      initialValue:
                                          llmSettingsMap!["userPrompt"],
                                      onChanged: (value) => setState(() =>
                                          llmSettingsMap!["userPrompt"] =
                                              value),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                                child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                minimumSize: const Size(130, 50),
                              ),
                              onPressed: () => setLLMSettings(llmSettingsMap!)
                                  .then((_) => Navigator.of(context).pop()),
                              child: Text("Save settings",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .fontSize)),
                            ))
                          ],
                        ))),
        ));
  }
}
