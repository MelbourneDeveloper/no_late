import 'package:test/test.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:no_late_analyzer/src/simple_rule.dart';

void main() {
  group('SimpleLateRule', () {
    late SimpleLateRule rule;

    setUp(() {
      rule = SimpleLateRule();
    });

    test('should flag late variables without initialization', () {
      const code = '''
class TestClass {
  late String name;
  late int age;
}
''';
      
      final result = parseString(content: code);
      final errors = rule.check(result.unit);
      
      expect(errors, hasLength(2));
      expect(errors[0].variableName, equals('name'));
      expect(errors[1].variableName, equals('age'));
      expect(errors[0].message, contains('declared late but not initialized'));
    });

    test('should flag late variables with simple literal initialization', () {
      const code = '''
class TestClass {
  late String name = "John";
  late int age = 25;
  late bool isActive = true;
}
''';
      
      final result = parseString(content: code);
      final errors = rule.check(result.unit);
      
      expect(errors, hasLength(3));
      expect(errors[0].variableName, equals('name'));
      expect(errors[1].variableName, equals('age'));
      expect(errors[2].variableName, equals('isActive'));
      expect(errors[0].message, contains('simple value'));
    });

    test('should allow late variables with lazy initialization', () {
      const code = '''
class TestClass {
  late final String timestamp = DateTime.now().toString();
  late final List<int> numbers = generateNumbers();
  late final Map<String, dynamic> config = loadConfig();
  
  List<int> generateNumbers() => [1, 2, 3];
  Map<String, dynamic> loadConfig() => {};
}
''';
      
      final result = parseString(content: code);
      final errors = rule.check(result.unit);
      
      expect(errors, isEmpty);
    });

    test('should handle local variables', () {
      const code = '''
void testFunction() {
  late String name;
  late int count = 42;
  late List<String> items = computeItems();
}

List<String> computeItems() => [];
''';
      
      final result = parseString(content: code);
      final errors = rule.check(result.unit);
      
      expect(errors, hasLength(2)); // name and count should be flagged
      expect(errors[0].variableName, equals('name'));
      expect(errors[1].variableName, equals('count'));
    });
  });
}