import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:test/test.dart';

void main() {
  group('NoDangerousLateUsageRule', () {
    test('identifies uninitialized late variable', () {
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

    test('identifies uninitialized late field', () {
      const code = '''
class MyClass {
  late int count;
  late final String id;
}
''';
      final unit = parseString(content: code).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(2));
      expect(lateVars[0].variables.first.initializer, isNull);
      expect(lateVars[1].variables.first.initializer, isNull);
    });

    test('identifies initialized late variable', () {
      const code = '''
class Test {
  late String name = _computeName();

  String _computeName() => 'test';
}
''';
      final unit = parseString(content: code).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(1));
      expect(lateVars.first.variables.first.initializer, isNotNull);
    });

    test('identifies late with function call initializer', () {
      const code = '''
late final database = openDatabase();

Database openDatabase() => Database();
class Database {}
''';
      final unit = parseString(content: code).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(1));
      expect(lateVars.first.variables.first.initializer, isNotNull);
    });

    test('identifies multiple uninitialized late variables', () {
      const code = '''
void main() {
  late String a;
  late int b;
  late double c;
}
''';
      final unit = parseString(content: code).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars.length, equals(3));
      for (final lateVar in lateVars) {
        expect(lateVar.variables.first.initializer, isNull);
      }
    });

    test('ignores non-late uninitialized variables', () {
      const code = '''
class Test {
  String? name;
  int? count;
}
''';
      final unit = parseString(content: code).unit;
      final lateVars = _findLateVariables(unit);

      expect(lateVars, isEmpty);
    });
  });
}

List<VariableDeclarationList> _findLateVariables(CompilationUnit unit) {
  final lateVars = <VariableDeclarationList>[];
  unit.accept(_LateVisitor(lateVars));
  return lateVars;
}

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
