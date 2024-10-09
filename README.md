# fake_review_creator

Fake review creator written in flutter. Consists of an ebay image scraper, an amazon review scraper
and and several llm api implementations for processing the reviews(currently
only [OpenRouter](https://openrouter.ai) and custom).

## How does it work?

The tool does the following:

1. Scrapes ebay for images of sold items
2. Scrapes amazon for reviews
   2.1. Feeds the scraped reviews into an LLM with a custom system prompt
3. (Coming soon): Checks the selected images on google images and imgur

## Installation

There is currently no installation option for the desktop versions. Just download the appropriate
binary for your platform from
the [release page](https://github.com/aegeontis/fake_review_creator/releases) and directly
execute it (double click / execute from terminal).

## Supported LLMs:

- Custom type: Just prints the system prompt + user prompt + reviews
- [OpenRouter](https://openrouter.ai): Mostly implemented
- [Ollama](https://openllama.com) (local llm): Coming soon
- [OpenAI](https://openai.com): Coming soon

## Building

1. Download and install the [dartsdk](https://dart.dev/get-dart)
2. Clone the repository: `git clone --depth=1 https://github.com/Aegeontis/fake_review_creator`
3. Change directory: `cd fake_review_creator`
4. Get the dependencies: `pub get`
5. Depending on your platform run:
   * Linux:
      * `flutter build linux --release`
      * Releases are packages with AppImage. The appImage directory is in linux/AppImageDir.
   * Windows:
      * `flutter build windows --release`
      * Releases are packaged
        with [msix](https://pub.dev/packages/msix): `flutter pub run msix:create`
   * MacOS: https://docs.flutter.dev/deployment/macos
   * iOS and Android are not yet supported