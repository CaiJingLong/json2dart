import 'dart:convert';
import 'dart:html';

void main() {
  querySelector("#format").onClick.listen((event) {
    TextAreaElement e = querySelector("#json");
    var string = e.value;
    var pretty = formatJson(string);
    e.value = pretty;
  });
}

String formatJson(String jsonString) {
  var map = json.decode(jsonString);
  var prettyStringList = JsonUtf8Encoder(" ").convert(map);
  var prettyString = String.fromCharCodes(prettyStringList);
  return prettyString;
}
