/// Identifies media envelopes produced by versions that supported binary
/// voice, image, and PDF transfers. They remain in local history but are not
/// rendered or fetched now that media transfer support has been removed.
bool isRetiredMediaMessage(String text) {
  return text.startsWith('VE3:') ||
      text.startsWith('IE4:') ||
      text.startsWith('PE1:') ||
      text.startsWith('!AUDIO:');
}
