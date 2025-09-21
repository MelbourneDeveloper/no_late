import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:no_late/no_late_analyzer.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run bin/analyze.dart <file.dart>');
    exit(1);
  }

  final filePath = args[0];
  final file = File(filePath);
  
  if (!file.existsSync()) {
    print('File not found: $filePath');
    exit(1);
  }

  print('Analyzing $filePath...\n');

  try {
    final parseResult = parseFile(path: filePath, featureSet: FeatureSet.latestLanguageVersion());
    
    final rule = SimpleLateRule();
    final errors = rule.check(parseResult.unit);

    if (errors.isEmpty) {
      print('✓ No late usage issues found!');
    } else {
      print('Found ${errors.length} late usage issue(s):\n');
      
      final content = file.readAsStringSync();
      final lines = content.split('\n');
      
      for (final error in errors) {
        // Find line number for the error
        var currentPos = 0;
        var lineNum = 0;
        
        for (var i = 0; i < lines.length; i++) {
          if (currentPos <= error.offset && 
              error.offset < currentPos + lines[i].length + 1) {
            lineNum = i + 1;
            break;
          }
          currentPos += lines[i].length + 1;
        }
        
        print('❌ Line $lineNum: ${error.variableName}');
        print('   ${error.message}');
        print('');
      }
    }
  } catch (e) {
    print('Error analyzing file: $e');
    exit(1);
  }
}