# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## How Doese Claude Know When the Project Is Working?

The bad late usage example (example/bad_late_usage.dart) has multiple cases where the analyzer should cause linting errors. When running the analyzer, these should show up. And vscode should show these in the Problems window.

If the custom lint does not recognise these issues as errors, the plugin is not working and you must continue until the do show up.

## Code Rules
- Improve code as you work by following these rules, simplifying and removing duplication
- NO DUPLICATION. Move files, code elements instead of copying them. Search for elements before adding them.
- NO PLACEHOLDERS!!! If you HAVE TO leave a section blank, fail LOUDLY by throwing an exception.
- NEVER cast or use the bang operator (!) or `dynamic` type. Always using pattern matching
- Tests must FAIL HARD. Don't add allowances and print warnings. Just FAIL!
- Keep functions under 20 lines long.
- No global state. Not even in tests
- NEVER use the late keyword in code for the analyzer
- Follow the linting rules in the austerity package
- Do not use Git commands unless explicitly requested
- Keep files under 500 LOC, even tests
- Document all public functions with Dart /// doc, especially the important ones
- Don't use if statements. Use pattern matching or ternaries instead.

## Documentation
Follow the custom lint package documentation here:
https://github.com/invertase/dart_custom_lint

## Project Overview
This is a Dart custom lint that enforces proper usage of the `late` keyword for lazy initialization only. It generates compiler errors when `late` is used improperly (e.g., for separate declaration/initialization or with simple literals).

Any use of the late keyword that COULD cause an exception is ILLEGAL and causes a static code analysis error

## Commands

### Testing
```bash
dart test
```

### Running a Single Test
```bash
dart test test/no_late_rule_test.dart --name "test name"
```

## Architecture

### Core Components

1. **SimpleLateRule** (`lib/src/simple_rule.dart`): Core rule logic that visits AST nodes to detect improper `late` usage. Returns `LateError` objects for violations.

2. **NoLatePlugin** (`lib/src/no_late_plugin.dart`): Analyzer plugin implementation that integrates with the Dart analyzer. Handles file watching, analysis requests, and sends error notifications to IDEs.

3. **Plugin Integration Points**:
   - Main plugin entry: `lib/src/no_late_plugin.dart:start()` - Started via isolate
   - User project integration: `tools/analyzer_plugin/bin/plugin.dart` - Bootstrap file users create
   - Plugin configuration: `tools/analyzer_plugin/pubspec.yaml` - Dependency declaration

### How the Plugin Works

1. The analyzer starts the plugin in an isolate via `start()` function
2. Plugin registers to analyze `**/*.dart` files
3. For each Dart file change, the plugin:
   - Parses the AST using the analyzer
   - Runs `SimpleLateRule.check()` to find violations
   - Converts violations to `AnalysisError` objects with line/column info
   - Sends errors back to the IDE via the analyzer protocol

### Error Detection Logic

The plugin flags two main violations:
- **Uninitialized late variables**: `late String name;` without immediate initialization
- **Simple literal initialization**: `late int count = 42;` with literals or simple identifiers

Allowed patterns include function calls, method invocations, and complex expressions that benefit from lazy evaluation.