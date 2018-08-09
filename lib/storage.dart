import 'dart:html';

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
}
