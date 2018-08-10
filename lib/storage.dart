import 'dart:html';

import 'package:json2dart_serialization/json_generator.dart';

const _entityKey = "entityKey";
const _versionKey = "versionKey";

class CookieHelper {
  String loadJsonString() {
    var storage = window.localStorage;
    if (!storage.containsKey("json")) {
      return "";
    }
    return window.localStorage["json"];
  }

  void saveJsonString(String jsonString) {
    window.localStorage.addAll({"json": jsonString});
  }

  void saveEntityName(String entityName) {
    window.localStorage.addAll({_entityKey: entityName});
  }

  String loadEntityName() {
    if (!window.localStorage.containsKey(_entityKey)) {
      return "";
    }
    return window.localStorage[_entityKey];
  }

  void saveVersion(Version version) {
    var index = Version.values.indexOf(version);
    window.localStorage.addAll({_versionKey: index.toString()});
  }

  Version loadVersion() {
    if (!window.localStorage.containsKey(_versionKey)) {
      return Version.v0;
    }

    return Version.values[int.parse(window.localStorage[_versionKey])];
  }
}
