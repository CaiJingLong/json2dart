import 'package:json2dart_serialization/template.dart';

class Generator {
  String jsonString;
  String fileName;
  Generator(this.jsonString, this.fileName);

  String makeDartCode() {
    Template template = DefaultTemplate();
    return jsonString;
  }

  static const String importString = "import 'package:json_annotation/json_annotation.dart';";

  String get header => """$importString 
  part $fileName.g.dart;""";
}
