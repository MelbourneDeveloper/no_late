import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// A custom lint rule that detects improper use of the 'late' keyword.
/// Only allows 'late' for lazy initialization with complex expressions.
class NoImproperLateUsageRule extends DartLintRule {
  NoImproperLateUsageRule() : super(code: _code);

  static const _code = LintCode(
    name: 'no_improper_late_usage',
    problemMessage: "The 'late' keyword should only be used for lazy initialization. Move the initialization to the declaration or use an expression.",
    correctionMessage: 'Remove late keyword or use it only for complex lazy initialization.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addVariableDeclarationList((node) {
      if (node.lateKeyword != null) {
        _checkLateUsage(node, reporter);
      }
    });
  }

  void _checkLateUsage(VariableDeclarationList node, ErrorReporter reporter) {
    for (final variable in node.variables) {
      if (variable.initializer == null) {
        // This is a late declaration without initialization - NOT ALLOWED
        reporter.atNode(
          variable,
          _code,
        );
      } else {
        // Check if the initializer is a simple literal
        final initializer = variable.initializer!;
        if (!_isLazyInitializer(initializer)) {
          reporter.atNode(
            variable,
            _code,
          );
        }
      }
    }
  }

  bool _isLazyInitializer(Expression initializer) {
    // Allow function calls, method calls, and complex expressions
    // Disallow simple literals and basic constructors
    return initializer is! Literal &&
           initializer is! ListLiteral &&
           initializer is! SetOrMapLiteral &&
           initializer is! SimpleIdentifier;
  }
}