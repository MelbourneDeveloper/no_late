import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:no_late/src/simple_rule.dart';
import 'package:test/test.dart';

void main() {
  group('NoImproperLateUsageRule', () {
    test('should flag late variables without initialization', () {
      final code = '''
class TestClass {
  // expect_lint: no_improper_late_usage
  late String name;
  // expect_lint: no_improper_late_usage
  late int age;
}
''';

      testRule(NoImproperLateUsageRule(), code);
    });

    test('should flag late variables with simple literal initialization', () {
      final code = '''
class TestClass {
  // expect_lint: no_improper_late_usage
  late String name = "John";
  // expect_lint: no_improper_late_usage
  late int age = 25;
  // expect_lint: no_improper_late_usage
  late bool isActive = true;
}
''';

      testRule(NoImproperLateUsageRule(), code);
    });

    test('should allow late variables with lazy initialization', () {
      final code = '''
class TestClass {
  late final String timestamp = DateTime.now().toString();
  late final List<int> numbers = generateNumbers();
  late final Map<String, dynamic> config = loadConfig();

  List<int> generateNumbers() => [1, 2, 3];
  Map<String, dynamic> loadConfig() => {};
}
''';

      testRule(NoImproperLateUsageRule(), code);
    });

    test('should handle local variables', () {
      final code = '''
void testFunction() {
  // expect_lint: no_improper_late_usage
  late String name;
  // expect_lint: no_improper_late_usage
  late int count = 42;
  late List<String> items = computeItems();
}

List<String> computeItems() => [];
''';

      testRule(NoImproperLateUsageRule(), code);
    });
  });
}
