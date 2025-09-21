# No Late Analyzer

A Dart analyzer plugin that enforces proper usage of the `late` keyword for lazy initialization only. This plugin will generate compiler errors if you use `late` in any other way than just lazy initialization.

## What This Plugin Does

This analyzer plugin detects and flags improper usage of the `late` keyword, specifically:

1. **Separate declaration and initialization** - Declaring a `late` variable without initialization and then initializing it later (e.g., in `initState`)
2. **Simple literal initialization** - Using `late` with simple literals like strings, numbers, or booleans

## Bad Usage Examples (Will Generate Errors)

```dart
class BadExample {
  // BAD: Separate declaration and initialization
  late String userName;
  late int userId;
  
  // BAD: Simple literal initialization
  late String title = "Hello World";
  late int count = 42;
  late bool isActive = true;
  
  void initState() {
    // BAD: Initializing late variables after declaration
    userName = "John Doe";
    userId = 123;
  }
}
```

## Good Usage Examples (Allowed)

```dart
class GoodExample {
  // GOOD: Lazy initialization with computed values
  late final String complexString = _computeComplexString();
  late final List<int> expensiveList = _generateExpensiveList();
  late final DateTime timestamp = DateTime.now();
  late final Random random = Random();
  
  String _computeComplexString() {
    return "Computed: ${DateTime.now().millisecondsSinceEpoch}";
  }
  
  List<int> _generateExpensiveList() {
    return List.generate(1000, (index) => index * index);
  }
}
```

## Installation

### Method 1: As an Analyzer Plugin

1. Add this plugin to your project:

```yaml
dev_dependencies:
  no_late_analyzer: ^1.0.0
```

2. Create a `tools/analyzer_plugin/pubspec.yaml` file in your project:

```yaml
name: analyzer_plugin
description: Analyzer plugin configuration

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  no_late_analyzer: ^1.0.0
```

3. Create a `tools/analyzer_plugin/bin/plugin.dart` file:

```dart
import 'dart:isolate';
import 'package:no_late_analyzer/no_late_analyzer.dart';

void main(List<String> args, SendPort sendPort) {
  start(args, sendPort);
}
```

4. Run `dart pub get` in both your main project and the `tools/analyzer_plugin` directory.

### Method 2: Standalone Usage

You can also use the rule directly in your code analysis:

```dart
import 'package:no_late_analyzer/no_late_analyzer.dart';
import 'package:analyzer/dart/analysis/utilities.dart';

void analyzeCode(String code) {
  final result = parseString(content: code);
  final rule = NoLateRule();
  final errors = rule.check(result.unit);
  
  for (final error in errors) {
    print('Error: ${error.message} at line ${error.offset}');
  }
}
```

## Error Messages

When improper `late` usage is detected, you'll see error messages like:

```
The 'late' keyword should only be used for lazy initialization. Separate declaration and initialization is not allowed.
```

## Why This Matters

The `late` keyword in Dart is intended for lazy initialization - deferring the computation of a value until it's first accessed. Using it for other purposes can:

1. **Confuse developers** about the intent of the code
2. **Hide initialization bugs** where variables might be accessed before being set
3. **Reduce performance** by adding unnecessary null checks
4. **Make code harder to reason about**

This analyzer helps enforce the intended usage pattern and keeps your code clean and performant.

## Testing

Run the tests with:

```bash
dart test
```

## License

MIT License - see LICENSE file for details.