import 'dart:convert';

import 'package:json2dart_serialization/template.dart';

class Generator {
  String jsonString;
  String entityName;

  Generator(this.jsonString, [this.entityName]);

  List<DefaultTemplate> templateList = [];

  String makeDartCode() {
    var entityName = this.entityName ?? "Entity";
    DefaultTemplate template = DefaultTemplate(srcJson: jsonString, className: entityName);
    StringBuffer resultSb = StringBuffer();
    templateList.add(template);
    refreshTemplate(template);

    resultSb.writeln(header);
    templateList.forEach((template) {
      resultSb.writeln(template.toString());
    });
    return resultSb.toString();
  }

  void refreshTemplate(DefaultTemplate template) {
    var fieldList = template.fieldList;
    fieldList.forEach((filed) {
      if (filed is MapField) {
//        filed.typeString
        DefaultTemplate template = DefaultTemplate(srcJson: json.encode(filed.map), className: filed.typeString);
        templateList.add(template);
        refreshTemplate(template);
      } else if (filed is ListField) {
        if (filed.childIsObject) {
          DefaultTemplate template = DefaultTemplate(srcJson: json.encode(filed.list[0]), className: filed.typeName);
          templateList.add(template);
          refreshTemplate(template);
        }
      }
    });
  }

  String get fileName => camelCase2UnderScoreCase(entityName);

  static const String importString = "import 'package:json_annotation/json_annotation.dart';";

  String get header => """$importString 
  
part '$fileName.g.dart';

""";
}

String camelCase2UnderScoreCase(String name) {
  return name[0].toLowerCase() +
      name.substring(1).replaceAllMapped(RegExp("[A-Z]"), (match) {
        var str = match.group(0);
        return "_" + str.toLowerCase();
      });
}
