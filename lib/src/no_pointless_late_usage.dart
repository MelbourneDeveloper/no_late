import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Detects pointless usage of 'late' keyword with simple initializers.
/// Flags late variables initialized with literals or simple identifiers.
class NoPointlessLateUsageRule extends DartLintRule {
  NoPointlessLateUsageRule() : super(code: _code);

  static const _code = LintCode(
    name: 'no_pointless_late_usage',
    problemMessage: "Using 'late' with simple values provides no benefit.",
    correctionMessage: "Remove 'late' for simple literal or identifier initialization.",
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
        final initializer = variable.initializer;
        if (initializer != null && _isSimpleInitializer(initializer)) {
          reporter.atNode(variable, _code);
        }
      }
    });
  }

  bool _isSimpleInitializer(Expression initializer) {
    return initializer is Literal ||
           initializer is ListLiteral ||
           initializer is SetOrMapLiteral ||
           initializer is SimpleIdentifier;
  }
}