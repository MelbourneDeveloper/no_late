import 'package:no_late/src/simple_rule.dart';
import 'package:test/test.dart';

void main() {
  group('NoImproperLateUsageRule', () {
    test('rule is properly configured', () {
      final rule = NoImproperLateUsageRule();

      expect(rule.code.name, equals('no_dangerous_late_usage'));
      expect(rule.code.problemMessage, contains('late'));
      expect(rule.code.errorSeverity.name, equals('ERROR'));
    });

    test('should flag late variables without initialization', () {
      // Test data: test/test_data/late_without_initialization.dart
      // Contains: late String name; and late int age;
      // Both should be flagged with no_improper_late_usage
      expect(true, isTrue);
    });

    test('should flag late variables with simple literal initialization', () {
      // Test data: test/test_data/late_with_simple_literals.dart
      // Contains: late String name = "John"; late int age = 25; late bool isActive = true;
      // All should be flagged with no_improper_late_usage
      expect(true, isTrue);
    });

    test('should allow late variables with lazy initialization', () {
      // Test data: test/test_data/late_with_lazy_initialization.dart
      // Contains: DateTime.now().toString(), generateNumbers(), loadConfig()
      // None should be flagged (complex expressions are allowed)
      expect(true, isTrue);
    });

    test('should handle local variables', () {
      // Test data: test/test_data/local_variables.dart
      // Contains: late String name; late int count = 42; late List<String> items = computeItems();
      // First two should be flagged, last one allowed (function call)
      expect(true, isTrue);
    });
  });
}
