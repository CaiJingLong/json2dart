import 'dart:convert';
import 'dart:html';

import 'package:json2dart_serialization/generator.dart';

void main() {
  TextAreaElement jsonInput = querySelector("#json");
  jsonInput.onInput.listen((event) {
    var string = jsonInput.value;
    String pretty;
    TextAreaElement result = querySelector("#result");
    try {
      pretty = formatJson(string);
    } on Exception {
      print("格式化错误");
      result.value = "不是一个正确的json";
      return;
    }

    var generator = Generator(string, 'test.dart');
    var dartCode = generator.makeDartCode();

    result.value = dartCode;
  });

  ButtonElement formatButton = querySelector("#format");
  formatButton.onClick.listen((click) {
    String pretty;
    try {
      pretty = formatJson(jsonInput.value);
    } on Exception {
      return;
    }
    jsonInput.value = pretty;
  });
}

String formatJson(String jsonString) {
  var map = json.decode(jsonString);
  var prettyString = JsonEncoder.withIndent("  ").convert(map);
  return prettyString;
}
