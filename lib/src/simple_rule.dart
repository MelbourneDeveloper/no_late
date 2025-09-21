import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// A simple rule that detects improper use of the 'late' keyword.
/// Returns a list of error messages for violations.
class SimpleLateRule {
  static const String ruleName = 'no_improper_late_usage';
  
  /// Check the compilation unit and return error messages
  List<LateError> check(CompilationUnit unit) {
    final visitor = _SimpleLateVisitor();
    unit.accept(visitor);
    return visitor.errors;
  }
}

/// Represents an error in late usage
class LateError {
  final String message;
  final int offset;
  final int length;
  final String variableName;

  LateError({
    required this.message,
    required this.offset,
    required this.length,
    required this.variableName,
  });

  @override
  String toString() => '$message (at $variableName:$offset)';
}

class _SimpleLateVisitor extends RecursiveAstVisitor<void> {
  final List<LateError> errors = [];

  @override
  void visitVariableDeclarationList(VariableDeclarationList node) {
    super.visitVariableDeclarationList(node);
    
    if (node.lateKeyword != null) {
      _checkLateUsage(node);
    }
  }

  void _checkLateUsage(VariableDeclarationList node) {
    for (final variable in node.variables) {
      final variableName = variable.name.lexeme;
      
      if (variable.initializer == null) {
        // This is a late declaration without initialization - NOT ALLOWED
        errors.add(LateError(
          message: "The 'late' keyword should only be used for lazy initialization. "
              "Variable '$variableName' is declared late but not initialized.",
          offset: variable.name.offset,
          length: variable.name.length,
          variableName: variableName,
        ));
      } else {
        // Check if the initializer is a simple literal
        final initializer = variable.initializer!;
        if (!_isLazyInitializer(initializer)) {
          errors.add(LateError(
            message: "The 'late' keyword should only be used for lazy initialization. "
                "Variable '$variableName' uses 'late' with a simple value.",
            offset: variable.name.offset,
            length: variable.name.length,
            variableName: variableName,
          ));
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