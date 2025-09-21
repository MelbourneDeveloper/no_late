import 'dart:isolate';
import 'package:no_late_analyzer_plugin/plugin_bootstrap.dart';

void main(List<String> args, SendPort sendPort) {
  start(args, sendPort);
}