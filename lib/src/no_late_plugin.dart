import 'dart:isolate';
import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/starter.dart';
import 'simple_rule.dart';

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
  String get name => 'no_late';

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
          SimpleLateRule.ruleName,
          correction: 'Use final or initialize immediately instead of late',
          hasFix: false,
        );
      }).toList();

      channel.sendNotification(
        AnalysisErrorsParams(path, analysisErrors).toNotification(),
      );
    } catch (e) {
      // Handle errors silently for now
    }
  }
}