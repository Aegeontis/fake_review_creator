import 'package:flutter/material.dart';

import '/backend/settings_manager.dart';

class AmazonSettingsScreen extends StatefulWidget {
  const AmazonSettingsScreen({super.key});

  @override
  State<AmazonSettingsScreen> createState() => _AmazonSettingsScreenState();
}

class _AmazonSettingsScreenState extends State<AmazonSettingsScreen> {
  Map<String, dynamic>? amazonSettingsMap;
  bool loadingSettings = true;

  @override
  void initState() {
    super.initState();
    getAmazonSettings().then((map) => setState(() {
          amazonSettingsMap = map;
          setState(() => loadingSettings = false);
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.primary),
          title: Center(
              child: Text("Amazon review scraper settings",
                  style: Theme.of(context).textTheme.headlineLarge)),
          actions: [
            TextButton(
                onPressed: () async {
                  setState(() {
                    loadingSettings = true;
                  });
                  await setDefaultAmazonSettings(forceReset: true);
                  amazonSettingsMap = await getAmazonSettings();
                  setState(() {
                    loadingSettings = false;
                  });
                },
                child: Text("Reset Amazon settings"))
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
                              title: TextFormField(
                                decoration: InputDecoration(
                                  hintText: "com, uk, de, fr, etc.",
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  isDense: true,
                                ),
                                initialValue:
                                    amazonSettingsMap!["domainSuffix"] != "com"
                                        ? amazonSettingsMap!["domainSuffix"]
                                        : null,
                                onChanged: (value) => setState(() =>
                                    amazonSettingsMap!["domainSuffix"] =
                                        value == "" ? "com" : value),
                              ),
                              leading: Text(
                                  "Domain suffix (default: amazon.com):",
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ),
                            const SizedBox(height: 5),
                            ListTile(
                              title: TextFormField(
                                decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  isDense: true,
                                ),
                                initialValue:
                                    amazonSettingsMap!["reviewsAmount"]
                                        .toString(),
                                onChanged: (value) => setState(() =>
                                    amazonSettingsMap!["reviewsAmount"] =
                                        value == ""
                                            ? 10
                                            : int.tryParse(value) ?? 10),
                              ),
                              leading: Text(
                                  "Amount of reviews to send to llm (default: 10):",
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ),
                            const SizedBox(height: 5),
                            ListTile(
                              title: const Text("Reverse sort reviews"),
                              trailing: Switch(
                                value: amazonSettingsMap!["lastPage"],
                                onChanged: (value) => setState(() =>
                                    amazonSettingsMap!["lastPage"] = value),
                              ),
                              onTap: () => setState(() =>
                                  amazonSettingsMap!["lastPage"] =
                                      !amazonSettingsMap!["lastPage"]),
                            ),
                            const SizedBox(height: 5),
                            ListTile(
                              title:
                                  const Text("Ignore foreign language reviews"),
                              trailing: Switch(
                                value:
                                    amazonSettingsMap!["ignoreForeignReviews"],
                                onChanged: (value) => setState(() =>
                                    amazonSettingsMap!["ignoreForeignReviews"] =
                                        value),
                              ),
                              onTap: () => setState(() => amazonSettingsMap![
                                      "ignoreForeignReviews"] =
                                  !amazonSettingsMap!["ignoreForeignReviews"]),
                            ),
                            const SizedBox(height: 5),
                            ListTile(
                              title: const Text(
                                  'Sort reviews by "recent" instead of "helpful"'),
                              trailing: Switch(
                                value: amazonSettingsMap!["sortByRecent"],
                                onChanged: (value) => setState(() =>
                                    amazonSettingsMap!["sortByRecent"] = value),
                              ),
                              onTap: () => setState(() =>
                                  amazonSettingsMap!["sortByRecent"] =
                                      !amazonSettingsMap!["sortByRecent"]),
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
                              onPressed: () =>
                                  setAmazonSettings(amazonSettingsMap!)
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
