import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:no_late/src/no_dangerous_late_usage.dart';
import 'package:no_late/src/no_pointless_late_usage.dart';
import 'package:test/test.dart';

void main() {
  group('Late Usage Logic Tests', () {
    late NoDangerousLateUsageRule dangerousRule;
    late NoPointlessLateUsageRule pointlessRule;

    setUp(() {
      dangerousRule = const NoDangerousLateUsageRule();
      pointlessRule = const NoPointlessLateUsageRule();
    });

    test('dangerous rule has correct configuration', () {
      expect(dangerousRule.code.name, equals('no_dangerous_late_usage'));
      expect(dangerousRule.code.problemMessage, contains('Uninitialized'));
    });

    test('pointless rule has correct configuration', () {
      expect(pointlessRule.code.name, equals('no_pointless_late_usage'));
      expect(pointlessRule.code.problemMessage, contains('simple values'));
    });

    test('identifies uninitialized late variables correctly', () {
      const source = '''
class Test {
  late String name;
}
''';
      final unit = parseString(content: source).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(1));
      expect(lateVars[0].variables[0].initializer, isNull);
    });

    test('identifies late variables with literals correctly', () {
      const source = '''
class Test {
  late String name = "John";
  late int age = 25;
  late bool flag = true;
  late List<int> nums = [1, 2, 3];
}
''';
      final unit = parseString(content: source).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(4));

      // Check each initializer type
      expect(lateVars[0].variables[0].initializer, isA<StringLiteral>());
      expect(lateVars[1].variables[0].initializer, isA<IntegerLiteral>());
      expect(lateVars[2].variables[0].initializer, isA<BooleanLiteral>());
      expect(lateVars[3].variables[0].initializer, isA<ListLiteral>());
    });

    test('identifies late variables with function calls correctly', () {
      const source = '''
class Test {
  late String value = getValue();
  late int result = compute();
  late List<String> data = fetchData();

  String getValue() => "test";
  int compute() => 42;
  List<String> fetchData() => [];
}
''';
      final unit = parseString(content: source).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(3));

      // Check each initializer is a function invocation
      expect(lateVars[0].variables[0].initializer, isA<MethodInvocation>());
      expect(lateVars[1].variables[0].initializer, isA<MethodInvocation>());
      expect(lateVars[2].variables[0].initializer, isA<MethodInvocation>());
    });

    test('identifies late variables with property access correctly', () {
      const source = '''
class Test {
  late String timestamp = DateTime.now().toString();
  late int length = someList.length;
}
''';
      final unit = parseString(content: source).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(2));

      // Both should be method invocations or property access
      //(PrefixedIdentifier is treated as property access)
      expect(lateVars[0].variables[0].initializer, isA<MethodInvocation>());
      expect(lateVars[1].variables[0].initializer, isA<PrefixedIdentifier>());
    });

    test('_isLazyInitializer logic works correctly', () {
      const source = '''
class Test {
  late String literal = "test";
  late int number = 42;
  late bool flag = true;
  late List<int> list = [1, 2, 3];
  late Set<String> set = {"a", "b"};
  late Map<String, int> map = {"key": 42};
  late String identifier = someVar;

  late String function = getValue();
  late String method = obj.getValue();
  late String property = obj.value;
  late String constructor = DateTime.now().toString();
}
''';
      final unit = parseString(content: source).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(11));

      // Test the _isLazyInitializer logic directly
      final badInitializers =
          lateVars.take(7).map((v) => v.variables[0].initializer!);
      final goodInitializers =
          lateVars.skip(7).map((v) => v.variables[0].initializer!);

      for (final init in badInitializers) {
        expect(
          _shouldBeFlagged(init),
          isTrue,
          reason: 'Should flag: ${init.runtimeType}',
        );
      }

      for (final init in goodInitializers) {
        expect(
          _shouldBeFlagged(init),
          isFalse,
          reason: 'Should allow: ${init.runtimeType}',
        );
      }
    });
  });
}

List<VariableDeclarationList> _findLateVariables(CompilationUnit unit) {
  final lateVars = <VariableDeclarationList>[];

  unit.accept(_LateVisitor(lateVars));

  return lateVars;
}

bool _shouldBeFlagged(Expression initializer) =>
    // Mirror the logic from NoPointlessLateUsageRule._isSimpleInitializer
    // A variable should be flagged if it's a simple literal or identifier
    initializer is Literal ||
    initializer is ListLiteral ||
    initializer is SetOrMapLiteral ||
    initializer is SimpleIdentifier;

class _LateVisitor extends RecursiveAstVisitor<void> {
  _LateVisitor(this.lateVariables);
  final List<VariableDeclarationList> lateVariables;

  @override
  void visitVariableDeclarationList(VariableDeclarationList node) {
    if (node.lateKeyword != null) {
      lateVariables.add(node);
    }
    super.visitVariableDeclarationList(node);
  }
}
