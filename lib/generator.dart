import 'dart:convert';

import 'package:json2dart_serialization/json_generator.dart';
import 'package:json2dart_serialization/template.dart';

class Generator {
  String jsonString;
  String entityName;
  Version version;

  Generator(this.jsonString, [this.entityName, this.version = Version.v0]) {
    this.jsonString = convertJsonString(jsonString);
  }

  List<DefaultTemplate> templateList = [];

  String makeDartCode() {
    var entityName = this.entityName ?? "Entity";
    DefaultTemplate template;
    if (version == Version.v1) {
      template = V1Template(srcJson: jsonString, className: entityName);
    } else {
      template = DefaultTemplate(srcJson: jsonString, className: entityName);
    }

    StringBuffer resultSb = StringBuffer();
    if (!template.isList) {
      templateList.add(template);
      refreshTemplate(template);
      // return resultSb.toString();
    } else {
      var listTemplate = template.getListTemplate();
      templateList.add(listTemplate);

      refreshTemplate(template);
    }

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
        DefaultTemplate template = DefaultTemplate(srcJson: json.encode(filed.map), className: filed.typeString);
        if (version == Version.v1) {
          template = V1Template(srcJson: json.encode(filed.map), className: filed.typeString);
        }
        templateList.add(template);
        refreshTemplate(template);
      } else if (filed is ListField) {
        if (filed.childIsObject) {
          DefaultTemplate template = DefaultTemplate(srcJson: json.encode(filed.list[0]), className: filed.typeName);
          if (version == Version.v1) {
            template = V1Template(srcJson: json.encode(filed.list[0]), className: filed.typeName);
          }
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

/// use the string replace's method the resolve the int and double problem.
String convertJsonString(String jsonString) {
  var numberReg = RegExp(r"[0-9]\.[0-9]+");

  //匹配小数数字正则
  var allMatch = numberReg.allMatches(jsonString).toList();

  for (var i = 0; i < allMatch.length; i++) {
    //是一个小数数字
    var m = allMatch[i];
    var s = m.group(0);

    // 应该是double，但由于js的原因被识别成了整数数，这里对这种数据进行处理，将这里的最后一位从0替换为5，以便于让该被js识别成小数 而非数字
    s = s.replaceRange(s.length - 1, s.length, "5");
    jsonString = jsonString.replaceRange(m.start, m.end, s);
  }
  return jsonString;
}
