import 'package:test/test.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

void main() {
  group('NoPointlessLateUsageRule', () {
    test('identifies late with string literal', () {
      const code = '''
class Test {
  late String name = 'test';
}
''';
      final unit = parseString(content: code).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(1));
      final initializer = lateVars.first.variables.first.initializer;
      expect(initializer, isA<StringLiteral>());
    });

    test('identifies late with numeric literal', () {
      const code = '''
void main() {
  late int count = 42;
  late double price = 99.99;
}
''';
      final unit = parseString(content: code).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(2));
      expect(lateVars[0].variables.first.initializer, isA<IntegerLiteral>());
      expect(lateVars[1].variables.first.initializer, isA<DoubleLiteral>());
    });

    test('identifies late with boolean literal', () {
      const code = '''
late bool isEnabled = true;
late bool isDisabled = false;
''';
      final unit = parseString(content: code).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(2));
      expect(lateVars[0].variables.first.initializer, isA<BooleanLiteral>());
      expect(lateVars[1].variables.first.initializer, isA<BooleanLiteral>());
    });

    test('identifies late with list literal', () {
      const code = '''
late final items = [1, 2, 3];
late List<String> names = ['alice', 'bob'];
''';
      final unit = parseString(content: code).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(2));
      expect(lateVars[0].variables.first.initializer, isA<ListLiteral>());
      expect(lateVars[1].variables.first.initializer, isA<ListLiteral>());
    });

    test('identifies late with map literal', () {
      const code = '''
late final config = {'key': 'value'};
late Map<int, String> lookup = {1: 'one', 2: 'two'};
''';
      final unit = parseString(content: code).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(2));
      expect(lateVars[0].variables.first.initializer, isA<SetOrMapLiteral>());
      expect(lateVars[1].variables.first.initializer, isA<SetOrMapLiteral>());
    });

    test('identifies late with simple identifier', () {
      const code = '''
String existingValue = 'test';
late String copy = existingValue;
''';
      final unit = parseString(content: code).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(1));
      expect(lateVars.first.variables.first.initializer, isA<SimpleIdentifier>());
    });

    test('identifies late with function call', () {
      const code = '''
class Test {
  late String computed = _compute();
  late final data = loadData();

  String _compute() => 'value';
  String loadData() => 'data';
}
''';
      final unit = parseString(content: code).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(2));
      expect(lateVars[0].variables.first.initializer, isA<MethodInvocation>());
      expect(lateVars[1].variables.first.initializer, isA<MethodInvocation>());
    });

    test('identifies late with method invocation', () {
      const code = '''
class Test {
  late String upper = 'test'.toUpperCase();
  late int length = 'hello'.length;
}
''';
      final unit = parseString(content: code).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(2));
      expect(lateVars[0].variables.first.initializer, isA<MethodInvocation>());
      expect(lateVars[1].variables.first.initializer, isA<PropertyAccess>());
    });

    test('identifies late with complex expression', () {
      const code = '''
class Test {
  late int result = 2 + 3 * 4;
  late String combined = 'hello' + ' world';
}
''';
      final unit = parseString(content: code).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(2));
      expect(lateVars[0].variables.first.initializer, isA<BinaryExpression>());
      expect(lateVars[1].variables.first.initializer, isA<BinaryExpression>());
    });

    test('ignores uninitialized late variable', () {
      const code = '''
class Test {
  late String name;
}
''';
      final unit = parseString(content: code).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(1));
      expect(lateVars.first.variables.first.initializer, isNull);
    });
  });
}

List<VariableDeclarationList> _findLateVariables(CompilationUnit unit) {
  final lateVars = <VariableDeclarationList>[];
  unit.accept(_LateVisitor(lateVars));
  return lateVars;
}

class _LateVisitor extends RecursiveAstVisitor<void> {
  final List<VariableDeclarationList> lateVariables;

  _LateVisitor(this.lateVariables);

  @override
  void visitVariableDeclarationList(VariableDeclarationList node) {
    if (node.lateKeyword != null) {
      lateVariables.add(node);
    }
    super.visitVariableDeclarationList(node);
  }
}