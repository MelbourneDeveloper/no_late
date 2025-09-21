import 'dart:isolate';
import 'package:no_late_analyzer/src/no_late_plugin.dart';

void main(List<String> args, SendPort sendPort) {
  start(args, sendPort);
}