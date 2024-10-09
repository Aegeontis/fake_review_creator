import "package:shared_preferences/shared_preferences.dart";

final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

void setDefaultSettings() async {
  await setDefaultEbaySettings();
  await setDefaultAmazonSettings();
  await setDefaultLLMSettings();
}

Future<void> setDefaultEbaySettings({forceReset = false}) async {
  // Check if settings exist
  if (!forceReset &&
      (await asyncPrefs.getString("ebay_domainSuffix")) != null) {
    print("Ebay settings already exist. Not setting default settings");
    return;
  }
  print("Setting default ebay settings");
  await asyncPrefs.setString("ebay_domainSuffix", "com");
  await asyncPrefs.setInt("ebay_sellerType", 1);
  await asyncPrefs.setBool("ebay_showCompleted", true);
  await asyncPrefs.setBool("ebay_showSold", true);
  await asyncPrefs.setBool("ebay_lastPage", true);
  await asyncPrefs.setInt("ebay_resultsAmount", 60);
  await asyncPrefs.setBool("ebay_conditionNew", false);
  await asyncPrefs.setBool("ebay_conditionOpenbox", false);
  await asyncPrefs.setBool("ebay_conditionRefurbishedCertified", false);
  await asyncPrefs.setBool("ebay_conditionRefurbishedExcellent", false);
  await asyncPrefs.setBool("ebay_conditionRefurbishedVeryGood", false);
  await asyncPrefs.setBool("ebay_conditionRefurbishedGood", false);
  await asyncPrefs.setBool("ebay_conditionUsed", true);
  await asyncPrefs.setBool("ebay_conditionBroken", false);
  await asyncPrefs.setBool("ebay_conditionUnspecified", false);
}

Future<void> setDefaultAmazonSettings({forceReset = false}) async {
  // Check if settings exist
  if (!forceReset &&
      (await asyncPrefs.getString("amazon_domainSuffix")) != null) {
    print("Amazon settings already exist. Not setting default settings");
    return;
  }
  print("Setting default amazon settings");
  await asyncPrefs.setString("amazon_domainSuffix", "com");
  await asyncPrefs.setInt("amazon_reviewsAmount", 10);
  await asyncPrefs.setBool("amazon_lastPage", true);
  await asyncPrefs.setBool("amazon_ignoreForeignReviews", false);
  await asyncPrefs.setBool("amazon_sortByRecent", false);
}

Future<void> setDefaultLLMSettings({forceReset = false}) async {
  // Check if settings exist
  if (!forceReset && (await asyncPrefs.getString("llm_instanceType")) != null) {
    print("LLM settings already exist. Not setting default settings");
    return;
  }
  print("Setting default LLM settings");
  await asyncPrefs.setString("llm_instanceType", "openRouter");
  await asyncPrefs.setString("llm_modelName", "google/gemma-2-9b-it:free");
  await asyncPrefs.setString("llm_accessKey", "");
  await asyncPrefs.setInt("llm_tokenSize", 260);
  await asyncPrefs.setString(
      "llm_userPrompt", "Write the review for [PRODUCT_NAME] in English.");
  await asyncPrefs.setString(
      "llm_systemPrompt",
      "You are a reviewer tasked with combining multiple reviews of a product into a single, cohesive review. Write in the first person. Follow these rules:\n\n"
          "- Do not mention other people, products, brands, purchase date, delivery details, or how long you’ve owned it.\n"
          "- Do not mention anything price-related or the price itself.\n"
          "- Do not create lists, bullet points, enumerations.\n"
          "- Do not mention review-writing habits.\n"
          "- Exclude any introduction or summary at the beginning or end of the review.\n"
          "- Exclude reasons for buying if the product is a replacement.\n"
          "- Ensure that the text flows naturally without any concluding statements or recaps.\n"
          "- Avoid mentioning specific numeric specifications of the product.");
}

Future<Map<String, dynamic>> getEbaySettings() async {
  print("Getting ebay settings");
  return {
    "domainSuffix": (await asyncPrefs.getString("ebay_domainSuffix"))!,
    "sellerType": (await asyncPrefs.getInt("ebay_sellerType"))!,
    "showCompleted": (await asyncPrefs.getBool("ebay_showCompleted"))!,
    "showSold": (await asyncPrefs.getBool("ebay_showSold"))!,
    "lastPage": (await asyncPrefs.getBool("ebay_lastPage"))!,
    "resultsAmount": (await asyncPrefs.getInt("ebay_resultsAmount"))!,
    "conditionNew": (await asyncPrefs.getBool("ebay_conditionNew"))!,
    "conditionOpenbox": (await asyncPrefs.getBool("ebay_conditionOpenbox"))!,
    "conditionRefurbishedCertified":
        (await asyncPrefs.getBool("ebay_conditionRefurbishedCertified"))!,
    "conditionRefurbishedExcellent":
        (await asyncPrefs.getBool("ebay_conditionRefurbishedExcellent"))!,
    "conditionRefurbishedVeryGood":
        (await asyncPrefs.getBool("ebay_conditionRefurbishedVeryGood"))!,
    "conditionRefurbishedGood":
        (await asyncPrefs.getBool("ebay_conditionRefurbishedGood"))!,
    "conditionUsed": (await asyncPrefs.getBool("ebay_conditionUsed"))!,
    "conditionBroken": (await asyncPrefs.getBool("ebay_conditionBroken"))!,
    "conditionUnspecified":
        (await asyncPrefs.getBool("ebay_conditionUnspecified"))!,
  };
}

Future<Map<String, dynamic>> getAmazonSettings() async {
  print("Getting amazon settings");
  return {
    "domainSuffix": (await asyncPrefs.getString("amazon_domainSuffix"))!,
    "reviewsAmount": (await asyncPrefs.getInt("amazon_reviewsAmount"))!,
    "lastPage": (await asyncPrefs.getBool("amazon_lastPage"))!,
    "ignoreForeignReviews":
        (await asyncPrefs.getBool("amazon_ignoreForeignReviews"))!,
    "sortByRecent": (await asyncPrefs.getBool("amazon_sortByRecent"))!,
  };
}

Future<Map<String, dynamic>> getLLMSettings() async {
  print("Getting LLM settings");
  return {
    "instanceType": (await asyncPrefs.getString("llm_instanceType"))!,
    "modelName": (await asyncPrefs.getString("llm_modelName"))!,
    "accessKey": (await asyncPrefs.getString("llm_accessKey"))!,
    "systemPrompt": (await asyncPrefs.getString("llm_systemPrompt"))!,
    "userPrompt": (await asyncPrefs.getString("llm_userPrompt"))!,
    "tokenSize": (await asyncPrefs.getInt("llm_tokenSize"))!,
  };
}

Future<void> setEbaySettings(Map<String, dynamic> settingsMap) async {
  print("Setting ebay settings");
  await asyncPrefs.setString("ebay_domainSuffix", settingsMap["domainSuffix"]);
  await asyncPrefs.setInt("ebay_sellerType", settingsMap["sellerType"]);
  await asyncPrefs.setBool("ebay_showCompleted", settingsMap["showCompleted"]);
  await asyncPrefs.setBool("ebay_showSold", settingsMap["showSold"]);
  await asyncPrefs.setBool("ebay_lastPage", settingsMap["lastPage"]);
  await asyncPrefs.setInt("ebay_resultsAmount", settingsMap["resultsAmount"]);
  await asyncPrefs.setBool("ebay_conditionNew", settingsMap["conditionNew"]);
  await asyncPrefs.setBool(
      "ebay_conditionOpenbox", settingsMap["conditionOpenbox"]);
  await asyncPrefs.setBool("ebay_conditionRefurbishedCertified",
      settingsMap["conditionRefurbishedCertified"]);
  await asyncPrefs.setBool("ebay_conditionRefurbishedExcellent",
      settingsMap["conditionRefurbishedExcellent"]);
  await asyncPrefs.setBool("ebay_conditionRefurbishedVeryGood",
      settingsMap["conditionRefurbishedVeryGood"]);
  await asyncPrefs.setBool(
      "ebay_conditionRefurbishedGood", settingsMap["conditionRefurbishedGood"]);
  await asyncPrefs.setBool("ebay_conditionUsed", settingsMap["conditionUsed"]);
  await asyncPrefs.setBool(
      "ebay_conditionBroken", settingsMap["conditionBroken"]);
  await asyncPrefs.setBool(
      "ebay_conditionUnspecified", settingsMap["conditionUnspecified"]);
}

Future<void> setAmazonSettings(Map<String, dynamic> settingsMap) async {
  print("Setting amazon settings");
  await asyncPrefs.setString(
      "amazon_domainSuffix", settingsMap["domainSuffix"]);
  await asyncPrefs.setInt("amazon_reviewsAmount", settingsMap["reviewsAmount"]);
  await asyncPrefs.setBool("amazon_lastPage", settingsMap["lastPage"]);
  await asyncPrefs.setBool(
      "amazon_ignoreForeignReviews", settingsMap["ignoreForeignReviews"]);
  await asyncPrefs.setBool("amazon_sortByRecent", settingsMap["sortByRecent"]);
}

Future<void> setLLMSettings(Map<String, dynamic> settingsMap) async {
  print("Setting LLM settings");
  await asyncPrefs.setString("llm_instanceType", settingsMap["instanceType"]);
  await asyncPrefs.setString("llm_accessKey", settingsMap["accessKey"]);
  await asyncPrefs.setString("llm_modelName", settingsMap["modelName"]);
  await asyncPrefs.setString("llm_userPrompt", settingsMap["userPrompt"]);
  await asyncPrefs.setString("llm_systemPrompt", settingsMap["systemPrompt"]);
  await asyncPrefs.setInt("llm_tokenSize", settingsMap["tokenSize"]);
}
