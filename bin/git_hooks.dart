import 'package:git_hooks/git_hooks.dart';
import 'dart:io';

void main(List<String> arguments) {
  Map<Git, UserBackFun> params = {Git.preCommit: preCommit};
  GitHooks.call(arguments, params);
}

Future<bool> preCommit() async {
  final flutterResult = await Process.run('flutter', ['format', '-l 120', '.']);
  if (flutterResult.exitCode != 0) return false;
  final String formatOutput = flutterResult.stdout;

  final formattedFiles = formatOutput.split('\n').where(extractOnlyFormattedFiles).map(extractFilePathFromFormatLine);

  final gitArgs = ['add', ...formattedFiles];
  final gitResult = await Process.run('git', gitArgs);
  return gitResult.exitCode == 0;
}

bool extractOnlyFormattedFiles(String line) => line.contains('Formatted');
String extractFilePathFromFormatLine(String line) => line.split(' ').last;
