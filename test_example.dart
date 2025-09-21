// ignore_for_file: unused_local_variable

class TestClass {
  // This should trigger the lint
  late String name;
  late int count = 42;

  // This should NOT trigger the lint
  late String value = getValue();
  late List<int> numbers = [1, 2, 3].map((x) => x * 2).toList();
}

String getValue() => 'test';

void testFunction() {
  // This should trigger the lint
  late String localName;
  late bool flag = true;

  // This should NOT trigger the lint
  late String computed = computeValue();
}

String computeValue() => 'computed';