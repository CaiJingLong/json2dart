void main() {}

String camelCase2UnderScoreCase(String name) {
  return name.replaceAllMapped(RegExp("[A-Z]"), (match) {
    var str = match.group(0);
    return "_" + str.toLowerCase();
  });
}
