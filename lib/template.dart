abstract class Template {
  String declare();

  String constructor();

  String field();

  String method();

  String end();
}

class DefaultTemplate extends Template {
  @override
  String constructor() {
    // TODO: implement constructor
  }

  @override
  String declare() {
    // TODO: implement declare
  }

  @override
  String end() {
    // TODO: implement end
  }

  @override
  String field() {
    // TODO: implement field
  }

  @override
  String method() {
    // TODO: implement method
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
