class TestClass {
  late final String timestamp = DateTime.now().toString();
  late final List<int> numbers = generateNumbers();
  late final Map<String, dynamic> config = loadConfig();

  List<int> generateNumbers() => [1, 2, 3];
  Map<String, dynamic> loadConfig() => {};
}