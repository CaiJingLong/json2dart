import 'dart:html';

const _entityKey = "entityKey";

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
}
