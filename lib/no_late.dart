import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:no_late/src/no_dangerous_late_usage.dart';
import 'package:no_late/src/no_pointless_late_usage.dart';

export 'src/no_dangerous_late_usage.dart';
export 'src/no_pointless_late_usage.dart';

/// Creates the plugin for no_late custom lint rules
PluginBase createPlugin() => _NoLatePlugin();

class _NoLatePlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        const NoDangerousLateUsageRule(),
        const NoPointlessLateUsageRule(),
      ];
}
