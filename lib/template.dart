import 'dart:convert';
import 'package:json2dart_serialization/json_generator.dart' as main;

abstract class Template {
  String declare();

  String constructor();

  String field();

  String method();

  String end();

  @override
  String toString() {
    return createCode(this);
  }
}

class DefaultTemplate extends Template {
  String srcJson;
  String className;

  String tab = "  ";

  DefaultTemplate({this.srcJson, this.className = "Entity"});

  @override
  String constructor() {
    var fieldList = FieldHelper(srcJson).getFields();
    var filedString = StringBuffer();
    fieldList.forEach((f) {
      String name;
      if (main.isCamelCase) {
        name = camelCase(f.nameString);
      } else {
        name = f.nameString;
      }
      filedString.write("this.$name,");
    });
    return "${tab}$className($filedString);";
  }

  @override
  String declare() {
    return """@JsonSerializable()
  class $className extends Object ${interface()}{""";
  }

  String interface() {
    return "with _\$${className}SerializerMixin";
  }

  @override
  String end() {
    return "}";
  }

  @override
  String field() {
//    var useJsonKey

    var fieldList = FieldHelper(srcJson).getFields();
    var sb = StringBuffer();
    fieldList.forEach((f) {
      sb.writeln();
      if (main.useJsonKey) {
        sb.writeln("  @JsonKey(name: '${f.nameString}')");
      }
      String nameString;
      if (main.isCamelCase) {
        nameString = firstLetterLower(camelCase(f.nameString));
      } else {
        nameString = f.nameString;
      }
      sb.writeln("  ${f.typeString} $nameString;");
    });
    return sb.toString();
  }

  String camelCase(String name) {
    StringBuffer sb = StringBuffer();
    var list = name.split("_");
    for (int i = 0; i < list.length; i++) {
      var item = list[i];
      String name = "";
      if (i == 0) {
        name = firstLetterLower(item);
      } else {
        name = firstLetterUpper(item);
      }
      sb.write(name);
    }
    return sb.toString();
  }

  @override
  String method() {
    return "  factory $className.fromJson(Map<String, dynamic> srcJson) => _\$${className}FromJson(srcJson);";
  }

  List<Field> get fieldList => FieldHelper(srcJson).getFields();

  bool get isList => json.decode(srcJson) is List;

  ListTemplate getListTemplate() {
    if (this is ListTemplate) {
      return this;
    }
    return ListTemplate(srcJson: srcJson, className: className, delegateTemplate: this);
  }
}

class ListTemplate extends DefaultTemplate {
  Template delegateTemplate;

  ListTemplate({String srcJson, String className = "Entity", this.delegateTemplate}) : super(className: className, srcJson: srcJson);

  @override
  String declare() {
    return _declareListMethod() + "\n" + delegateTemplate?.declare() ?? super.declare();
  }

  String _declareListMethod() {
    var listMethod = """List<$className> get${className}List(List<dynamic> list){
    List<$className> result = [];
    list.forEach((item){
      result.add($className.fromJson(item));
    });
    return result;
  }""";
    return listMethod;
  }

  @override
  String constructor() {
    return delegateTemplate?.constructor() ?? super.constructor();
  }

  @override
  String field() {
    return delegateTemplate?.field() ?? super.field();
  }

  @override
  String method() {
    return delegateTemplate?.method() ?? super.method();
  }

  @override
  String end() {
    return delegateTemplate?.end() ?? super.end();
  }

  @override
  List<Field> get fieldList => FieldHelper(json.encode(json.decode(srcJson)[0])).getFields();
}

class V1Template extends DefaultTemplate {
  V1Template({String srcJson, String className = "Entity"}) : super(className: className, srcJson: srcJson);

  @override
  String interface() => "";

  @override
  String method() {
    var result = StringBuffer();
    result.writeln(super.method());
    result.writeln();
    result.write("  Map<String, dynamic> toJson() => _\$${className}ToJson(this);");
    return result.toString();
  }
}

class FieldHelper {
  String srcJson;

  FieldHelper(this.srcJson);

  List<Field> _getMapFiled(Map<String, dynamic> map) {
    List<Field> list = [];
    map.forEach((k, v) {
      if (v is List) {
        list.add(ListField(v, k));
      } else if (v is String) {
        list.add(SimpleField("String", k));
      } else if (v is int) {
        list.add(SimpleField("num", k));
      } else if (v is double) {
        list.add(SimpleField("double", k));
      } else if (v is bool) {
        list.add(SimpleField("bool", k));
      } else if (v is Map<String, dynamic>) {
        list.add(MapField(v, k));
      }
    });
    return list;
  }

  List<Field> getFields() {
    var j = json.decode(srcJson);
    if (j is Map<String, dynamic>) {
      return _getMapFiled(j);
    } else if (j is List) {
      var item = j[0];
      if (item is Map<String, dynamic>) {
        return _getMapFiled(item);
      }
    }
    return [];
  }
}

abstract class Field {
  String get typeString;

  String get nameString;
}

class SimpleField extends Field {
  @override
  String typeString;

  @override
  String nameString;

  SimpleField(this.typeString, this.nameString);
}

class ListField extends Field {
  List<dynamic> list;

  @override
  String nameString;

  ListField(this.list, this.nameString);

  bool get childIsObject {
    if (list == null || list.isEmpty) {
      return false;
    }
    if (list[0] is Map<String, dynamic>) {
      return true;
    }
    return false;
  }

  String get typeName {
    String type = "dynamic";
    if (list == null || list.isEmpty) {
      return type;
    }
    var item = list[0];

    if (item is List) {
      type = "${ListField(item, "").typeString}";
    } else if (item is Map<String, dynamic>) {
      type = "${firstLetterUpper(nameString)}";
    } else if (item is num) {
      type = "int";
    } else if (item is double) {
      type = "double";
    } else if (item is String) {
      type = "String";
    } else if (item is bool) {
      type = "bool";
    }

    return type;
  }

  @override
  String get typeString {
    return "List<$typeName>";
  }
}

class MapField extends Field {
  Map<String, dynamic> map;
  String nameString;

  MapField(this.map, this.nameString);

  @override
  String get typeString {
    return firstLetterUpper(nameString);
  }
}

String createCode(Template template) {
  var code = """${template.declare()}
${template.field()}
${template.constructor()}

${template.method()}

${template.end()}

  """;
  return code;
}

String firstLetterUpper(String value) {
  if (value == null || value.isEmpty) {
    return "";
  }
  return value[0].toUpperCase() + value.substring(1);
}

String firstLetterLower(String value) {
  if (value == null || value.isEmpty) {
    return "";
  }
  return value[0].toLowerCase() + value.substring(1);
}
