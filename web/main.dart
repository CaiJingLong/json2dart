import 'dart:convert';
import 'dart:html';

import 'package:json2dart_serialization/generator.dart';

void main() {
  querySelector("#format").onClick.listen((event) {
    TextAreaElement e = querySelector("#json");
    var string = e.value;
    var pretty = formatJson(string);
    e.value = pretty;

    var generator = Generator(string, 'test.dart');
    var dartCode = generator.makeDartCode();
    TextAreaElement result = querySelector("#result");
    result.value = dartCode;
  });
}

String formatJson(String jsonString) {
  var map = json.decode(jsonString);
  var prettyString = JsonEncoder.withIndent("  ").convert(map);
  return prettyString;
}
