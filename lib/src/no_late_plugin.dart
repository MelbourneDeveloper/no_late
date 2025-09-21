import 'dart:isolate';
import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/starter.dart';
import 'package:no_late_analyzer/src/simple_rule.dart';

void start(List<String> args, SendPort sendPort) {
  ServerPluginStarter(NoLatePlugin()).start(sendPort);
}

class NoLatePlugin extends ServerPlugin {
  static const String _contactInfo = 'https://github.com/yourname/no_late';

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
  Future<void> analyzeFile({
    required AnalysisContext analysisContext,
    required String path,
  }) async {
    try {
      final result = await analysisContext.currentSession.getResolvedUnit(path);
      
      if (result is! ResolvedUnitResult) {
        return;
      }
      
      final rule = SimpleLateRule();
      final errors = rule.check(result.unit);
      
      if (errors.isEmpty) return;
      
      final analysisErrors = errors.map((error) {
        return AnalysisError(
          AnalysisErrorSeverity.ERROR,
          AnalysisErrorType.LINT,
          Location(
            path,
            error.offset,
            error.length,
            1, // line number (simplified for now)
            1, // column number (simplified for now)
          ),
          error.message,
          SimpleLateRule.ruleName,
        );
      }).toList();
      
      channel.sendNotification(
        AnalysisErrorsParams(path, analysisErrors).toNotification(),
      );
    } catch (e) {
      // Silently ignore errors for now
    }
  }
}