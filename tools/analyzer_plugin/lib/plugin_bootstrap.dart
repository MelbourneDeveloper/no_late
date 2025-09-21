import 'dart:isolate';
import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/starter.dart';

void start(List<String> args, SendPort sendPort) {
  print('[NO_LATE_PLUGIN] Starting plugin...');
  ServerPluginStarter(NoLatePlugin()).start(sendPort);
}

class NoLatePlugin extends ServerPlugin {
  static const String _contactInfo = 'https://github.com/yourname/no_late';
  
  late AnalysisContextCollection _contextCollection;

  @override
  String get contactInfo => _contactInfo;

  @override
  List<String> get fileGlobsToAnalyze => const ['**/*.dart'];

  @override
  String get name => 'no_late_analyzer';

  @override
  String get version => '1.0.0';

  NoLatePlugin() : super(resourceProvider: PhysicalResourceProvider.INSTANCE);

  @override
  Future<void> afterNewContextCollection({
    required AnalysisContextCollection contextCollection,
  }) async {
    print('[NO_LATE_PLUGIN] Setting up context collection...');
    _contextCollection = contextCollection;

    await super.afterNewContextCollection(
      contextCollection: contextCollection,
    );

    for (final context in contextCollection.contexts) {
      final analyzedFiles = context.contextRoot.analyzedFiles();
      print('[NO_LATE_PLUGIN] Found ${analyzedFiles.length} files to analyze');
      for (final path in analyzedFiles) {
        if (path.endsWith('.dart')) {
          await _analyzeFile(context, path);
        }
      }
    }
  }
  
  @override
  Future<AnalysisHandleWatchEventsResult> handleAnalysisHandleWatchEvents(
      AnalysisHandleWatchEventsParams parameters) async {
    for (final event in parameters.events) {
      final path = event.path;
      if (!path.endsWith('.dart')) continue;
      
      try {
        final context = _contextCollection.contextFor(path);
        await _analyzeFile(context, path);
      } catch (e) {
        // Ignore errors
      }
    }
    return AnalysisHandleWatchEventsResult();
  }
  
  @override
  Future<AnalysisSetPriorityFilesResult> handleAnalysisSetPriorityFiles(
      AnalysisSetPriorityFilesParams parameters) async {
    for (final path in parameters.files) {
      if (!path.endsWith('.dart')) continue;
      
      try {
        final context = _contextCollection.contextFor(path);
        await _analyzeFile(context, path);
      } catch (e) {
        // Ignore errors
      }
    }
    
    return AnalysisSetPriorityFilesResult();
  }
  
  @override
  Future<AnalysisUpdateContentResult> handleAnalysisUpdateContent(
      AnalysisUpdateContentParams parameters) async {
    final paths = parameters.files.keys.toSet();
    for (final path in paths) {
      if (!path.endsWith('.dart')) continue;
      
      try {
        final context = _contextCollection.contextFor(path);
        await _analyzeFile(context, path);
      } catch (e) {
        // Ignore errors
      }
    }
    
    return AnalysisUpdateContentResult();
  }
  
  @override
  Future<void> analyzeFile({
    required AnalysisContext analysisContext,
    required String path,
  }) async {
    await _analyzeFile(analysisContext, path);
  }
  
  Future<void> _analyzeFile(AnalysisContext context, String path) async {
    try {
      final result = await context.currentSession.getResolvedUnit(path);
      
      if (result is! ResolvedUnitResult) {
        channel.sendNotification(
          AnalysisErrorsParams(path, []).toNotification(),
        );
        return;
      }
      
      final rule = SimpleLateRule();
      final errors = rule.check(result.unit);
      
      final lineInfo = result.lineInfo;
      
      final analysisErrors = errors.map((error) {
        final startLocation = lineInfo.getLocation(error.offset);
        final endLocation = lineInfo.getLocation(error.offset + error.length);
        
        return AnalysisError(
          AnalysisErrorSeverity.ERROR,
          AnalysisErrorType.LINT,
          Location(
            path,
            error.offset,
            error.length,
            startLocation.lineNumber,
            startLocation.columnNumber,
            endLine: endLocation.lineNumber,
            endColumn: endLocation.columnNumber,
          ),
          error.message,
          'no_late',
          correction: 'Consider using final or initializing immediately',
          hasFix: false,
        );
      }).toList();
      
      channel.sendNotification(
        AnalysisErrorsParams(path, analysisErrors).toNotification(),
      );
    } catch (e) {
      // Log errors silently
    }
  }
}

class SimpleLateRule {
  static const String ruleName = 'no_late';

  List<LintError> check(CompilationUnit unit) {
    final visitor = _LateFieldVisitor();
    unit.accept(visitor);
    return visitor.errors;
  }
}

class LintError {
  final int offset;
  final int length;
  final String message;

  LintError({
    required this.offset,
    required this.length,
    required this.message,
  });
}

class _LateFieldVisitor extends RecursiveAstVisitor<void> {
  final List<LintError> errors = [];

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    _checkVariableList(node.fields);
    super.visitFieldDeclaration(node);
  }

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    _checkVariableList(node.variables);
    super.visitVariableDeclarationStatement(node);
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    _checkVariableList(node.variables);
    super.visitTopLevelVariableDeclaration(node);
  }

  void _checkVariableList(VariableDeclarationList variables) {
    if (variables.isLate) {
      for (final variable in variables.variables) {
        final variableName = variable.name.lexeme;

        // Check for late without initializer
        if (variable.initializer == null) {
          errors.add(LintError(
            offset: variable.name.offset,
            length: variable.name.length,
            message: "Avoid using 'late' without an initializer. Variable '$variableName' is declared late but not initialized.",
          ));
        } else {
          // Check for late with simple literal initializer
          final initializer = variable.initializer!;
          if (_isSimpleLiteral(initializer)) {
            errors.add(LintError(
              offset: variable.name.offset,
              length: variable.name.length,
              message: "Avoid using 'late' with simple literals. Variable '$variableName' uses 'late' unnecessarily.",
            ));
          }
        }
      }
    }
  }

  bool _isSimpleLiteral(Expression expr) {
    return expr is Literal ||
           expr is ListLiteral ||
           expr is SetOrMapLiteral ||
           (expr is SimpleIdentifier && (expr.name == 'true' || expr.name == 'false'));
  }
}