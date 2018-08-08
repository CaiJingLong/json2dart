import 'dart:convert';
import 'dart:html';

import 'package:json2dart_serialization/generator.dart';

String entityName = null;

bool useJsonKey = true;

bool isCamelCase = true;

var downloadFileName = "";

const defaultValue = """{
  "body": "",
  "data": [1],
  "input_content":["1"],
  "list1":[{"name":"hello"}],
  "number": [1.02],
  "user":{"name":"abc"}
}""";

void main() {
  TextAreaElement jsonInput = querySelector("#json");
  jsonInput.value = defaultValue;

  jsonInput.onInput.listen((event) {
    refreshData();
  });

  InputElement entityNameEle = querySelector("#out_entity_name");
  entityNameEle.onInput.listen((event) {
    entityName = entityNameEle.value;
    refreshData();
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

  InputElement eJsonKey = querySelector("#use_json_key");
  InputElement eCamelCase = querySelector("#camelCase");
  TextAreaElement result = querySelector("#result");

  void onJsonKeyChange() {
    useJsonKey = eJsonKey.checked;
    eCamelCase.disabled = !useJsonKey;
    isCamelCase = eCamelCase.checked;
    if (!useJsonKey) isCamelCase = false;
    refreshData();
  }

  eJsonKey.checked = useJsonKey;
  eJsonKey.onInput.listen((event) {
    onJsonKeyChange();
  });

  querySelector("#check_label").onClick.listen((event) {
    eJsonKey.checked = !eJsonKey.checked;
    onJsonKeyChange();
  });

  eCamelCase.checked = isCamelCase;
  eCamelCase.onInput.listen((event) {
    isCamelCase = eCamelCase.checked;
    refreshData();
  });

  querySelector("#camelCaseLabel").onClick.listen((event) {
    eCamelCase.checked = !eCamelCase.checked;
    refreshData();
  });

  refreshData();

  querySelector("#copy").onClick.listen((event) {
    result.focus();
    result.setSelectionRange(0, result.textLength);
    document.execCommand("copy", null, "");
    result.blur();
  });

  ButtonElement saveButton = querySelector("#save");
  saveButton.onClick.listen((event) async {
    Blob blob = Blob([result.value]);
    // FileSystem _filesystem =
    //     await window.requestFileSystem(1024 * 1024, persistent: false);
    // FileEntry fileEntry = await _filesystem.root.createFile('dart_test.csv');
    // FileWriter fw = await fileEntry.createWriter();
    // fw.write(blob);
    // File file = await fileEntry.file();
    AnchorElement saveLink = document.createElementNS("http://www.w3.org/1999/xhtml", "a");
    saveLink.href = Url.createObjectUrlFromBlob(blob);
    // saveLink.type = "download";
    saveLink.download = downloadFileName;
    saveLink.click();
  });
}

void refreshData() {
  TextAreaElement jsonInput = querySelector("#json");
  var string = jsonInput.value;
  String pretty;
  TextAreaElement result = querySelector("#result");
  try {
    pretty = formatJson(string);
  } on Exception {
    result.value = "不是一个正确的json";
    return;
  }
  String entityClassName;
  if (entityName == null || entityName == "" || entityName.trim() == "") {
    entityClassName = "Entity";
  } else {
    entityClassName = entityName;
  }

  var generator = Generator(string, entityClassName);
  var dartCode = generator.makeDartCode();
  var dartFileName = ("${generator.fileName}.dart");
  downloadFileName = dartFileName;
  querySelector("#file_name").text = "应该使用的文件名为: $dartFileName";

  result.value = dartCode;
}

String formatJson(String jsonString) {
  var map = json.decode(jsonString);
  var prettyString = JsonEncoder.withIndent("  ").convert(map);
  return prettyString;
}
