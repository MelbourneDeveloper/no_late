library no_late;

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'src/simple_rule.dart';

export 'src/simple_rule.dart';

/// Creates the plugin for no_late custom lint rules
PluginBase createPlugin() => _NoLatePlugin();

class _NoLatePlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    NoImproperLateUsageRule(),
  ];
}