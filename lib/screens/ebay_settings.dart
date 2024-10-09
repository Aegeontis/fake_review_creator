import 'package:flutter/material.dart';

import '/backend/settings_manager.dart';

class EbaySettingsScreen extends StatefulWidget {
  const EbaySettingsScreen({super.key});

  @override
  State<EbaySettingsScreen> createState() => _EbaySettingsScreenState();
}

class _EbaySettingsScreenState extends State<EbaySettingsScreen> {
  Map<String, dynamic>? ebaySettingsMap;
  bool loadingSettings = true;

  @override
  void initState() {
    super.initState();
    getEbaySettings().then((map) => setState(() {
          ebaySettingsMap = map;
          setState(() => loadingSettings = false);
        }));
  }

  void showSellerTypePopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Seller type"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: Text("All sellers",
                        style: Theme.of(context).textTheme.bodyLarge),
                    value: ebaySettingsMap!["sellerType"] == 0,
                    onChanged: (_) {
                      setState(() {
                        ebaySettingsMap!["sellerType"] = 0;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text("Private only",
                        style: Theme.of(context).textTheme.bodyLarge),
                    value: ebaySettingsMap!["sellerType"] == 1,
                    onChanged: (_) {
                      setState(() {
                        ebaySettingsMap!["sellerType"] = 1;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text("Commercial only",
                        style: Theme.of(context).textTheme.bodyLarge),
                    value: ebaySettingsMap!["sellerType"] == 2,
                    onChanged: (_) {
                      setState(() {
                        ebaySettingsMap!["sellerType"] = 2;
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
                      setEbaySettings(ebaySettingsMap!);
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
  }

  void showResultsAmountPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Results amount"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: Text("60",
                        style: Theme.of(context).textTheme.bodyLarge),
                    value: ebaySettingsMap!["resultsAmount"] == 60,
                    onChanged: (_) {
                      setState(() {
                        ebaySettingsMap!["resultsAmount"] = 60;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text("120",
                        style: Theme.of(context).textTheme.bodyLarge),
                    value: ebaySettingsMap!["resultsAmount"] == 120,
                    onChanged: (_) {
                      setState(() {
                        ebaySettingsMap!["resultsAmount"] = 120;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text("240",
                        style: Theme.of(context).textTheme.bodyLarge),
                    value: ebaySettingsMap!["resultsAmount"] == 240,
                    onChanged: (_) {
                      setState(() {
                        ebaySettingsMap!["resultsAmount"] = 240;
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
                      setEbaySettings(ebaySettingsMap!);
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
  }

  void showConditionPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Allowed item conditions"),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                ...[
                  {"label": "Condition: new", "key": "conditionNew"},
                  {"label": "Condition: open box", "key": "conditionOpenbox"},
                  {
                    "label": "Condition: refurbished certified",
                    "key": "conditionRefurbishedCertified"
                  },
                  {
                    "label": "Condition: refurbished excellent",
                    "key": "conditionRefurbishedExcellent"
                  },
                  {
                    "label": "Condition: refurbished very good",
                    "key": "conditionRefurbishedVeryGood"
                  },
                  {
                    "label": "Condition: refurbished good",
                    "key": "conditionRefurbishedGood"
                  },
                  {"label": "Condition: used", "key": "conditionUsed"},
                  {"label": "Condition: broken", "key": "conditionBroken"},
                  {
                    "label": "Condition: unspecified",
                    "key": "conditionUnspecified"
                  }
                ].map((condition) => CheckboxListTile(
                      title: Text(condition["label"]!,
                          style: Theme.of(context).textTheme.bodyLarge),
                      value: ebaySettingsMap![condition["key"]!],
                      onChanged: (value) {
                        setState(() {
                          ebaySettingsMap![condition["key"]!] = value;
                        });
                      },
                    ))
              ]),
              actions: [
                Center(
                  child: TextButton(
                    child: const Text("Apply"),
                    onPressed: () {
                      setEbaySettings(ebaySettingsMap!);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.primary),
          title: Center(
              child: Text("Ebay image scraper settings",
                  style: Theme.of(context).textTheme.headlineLarge)),
          actions: [
            TextButton(
                onPressed: () async {
                  setState(() {
                    loadingSettings = true;
                  });
                  await setDefaultEbaySettings(forceReset: true);
                  ebaySettingsMap = await getEbaySettings();
                  setState(() {
                    loadingSettings = false;
                  });
                },
                child: Text("Reset Ebay settings"))
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
                                    ebaySettingsMap!["domainSuffix"] != "com"
                                        ? ebaySettingsMap!["domainSuffix"]
                                        : null,
                                onChanged: (value) => setState(() =>
                                    ebaySettingsMap!["domainSuffix"] =
                                        value == "" ? "com" : value),
                              ),
                              leading: Text(
                                  "Domain suffix (default: ebay.com):",
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ),
                            ListTile(
                              title: const Text("Seller type"),
                              trailing: Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Icon(Icons.arrow_forward)),
                              onTap: () => showSellerTypePopup(),
                            ),
                            const SizedBox(height: 5),
                            ListTile(
                              title: const Text("Show completed items"),
                              trailing: Switch(
                                value: ebaySettingsMap!["showSold"],
                                onChanged: (value) => setState(
                                    () => ebaySettingsMap!["showSold"] = value),
                              ),
                              onTap: () => setState(() =>
                                  ebaySettingsMap!["showSold"] =
                                      !ebaySettingsMap!["showSold"]),
                            ),
                            const SizedBox(height: 5),
                            ListTile(
                              title: const Text("Show sold items"),
                              trailing: Switch(
                                value: ebaySettingsMap!["showCompleted"],
                                onChanged: (value) => setState(() =>
                                    ebaySettingsMap!["showCompleted"] = value),
                              ),
                              onTap: () => setState(() =>
                                  ebaySettingsMap!["showCompleted"] =
                                      !ebaySettingsMap!["showCompleted"]),
                            ),
                            const SizedBox(height: 5),
                            ListTile(
                              title: const Text("Show last results page"),
                              trailing: Switch(
                                value: ebaySettingsMap!["lastPage"],
                                onChanged: (value) => setState(
                                    () => ebaySettingsMap!["lastPage"] = value),
                              ),
                              onTap: () => setState(() =>
                                  ebaySettingsMap!["lastPage"] =
                                      !ebaySettingsMap!["lastPage"]),
                            ),
                            const SizedBox(height: 5),
                            ListTile(
                              title: const Text("Results per page"),
                              trailing: Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Icon(Icons.arrow_forward)),
                              onTap: () => showResultsAmountPopup(),
                            ),
                            const SizedBox(height: 5),
                            ListTile(
                              title: const Text("Allowed item conditions"),
                              trailing: Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Icon(Icons.arrow_forward)),
                              onTap: () => showConditionPopup(),
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
                              onPressed: () => setEbaySettings(ebaySettingsMap!)
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
