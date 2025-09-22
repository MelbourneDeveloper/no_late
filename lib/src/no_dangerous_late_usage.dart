import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detects dangerous usage of 'late' keyword that can cause runtime errors.
/// Flags uninitialized late variables.
class NoDangerousLateUsageRule extends DartLintRule {
  NoDangerousLateUsageRule() : super(code: _code);

  static const _code = LintCode(
    name: 'no_dangerous_late_usage',
    problemMessage: "Uninitialized 'late' variables can cause runtime errors.",
    correctionMessage: "Initialize the variable at declaration or remove 'late'.",
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addVariableDeclarationList((node) {
      final lateKeyword = node.lateKeyword;
      if (lateKeyword == null) return;

      for (final variable in node.variables) {
        if (variable.initializer == null) {
          reporter.atNode(variable, _code);
        }
      }
    });
  }
}