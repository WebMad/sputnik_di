import 'dart:io';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:path/path.dart' as path;
import 'package:sputnik_di_graph_visualizer/src/deps_node_visitor.dart';
import 'package:sputnik_di_graph_visualizer/src/deps_nodes_export.dart';

Future<void> main(List<String> arguments) async {
  // Путь к текущему пакету
  final packagePath = path.current;

  // Пути к директориям lib и lib/src
  final packageLib = path.join(packagePath, 'lib');
  final packageSrc = path.join(packageLib, 'src');

  // Создаем коллекцию контекстов анализа
  final collection = AnalysisContextCollection(
    includedPaths: [packagePath, packageLib, packageSrc],
    resourceProvider: PhysicalResourceProvider.INSTANCE,
  );

  // Получаем контекст анализа для текущего пакета
  final analysisContext = collection.contextFor(packagePath);

  // Получаем все файлы в контексте анализа
  final analyzedFiles = analysisContext.contextRoot.analyzedFiles();

  final depsNodeVisitor = DepsNodeVisitor();

  // Обходим все файлы
  for (final filePath in analyzedFiles) {
    // Пропускаем не Dart-файлы
    if (!filePath.endsWith('.dart')) continue;

    // Получаем результат анализа для файла
    final resolvedUnit =
        await analysisContext.currentSession.getResolvedUnit(filePath);

    if (resolvedUnit is ResolvedUnitResult) {
      // Обрабатываем AST файла
      resolvedUnit.libraryElement.accept(depsNodeVisitor);
    }
  }

  final depsNodeToMermaid = DepsNodesToMermaid(depsNodeVisitor.deps);
  final file = await File('deps_node_graph.txt').open(mode: FileMode.write);
  await file.writeString(depsNodeToMermaid.export());

  final depsNodeToPlantUml = DepsNodesToPlantUml(depsNodeVisitor.deps);
  final plantUmlFile =
      await File('deps_node_graph_plantuml.txt').open(mode: FileMode.write);
  await plantUmlFile.writeString(depsNodeToPlantUml.export());
}
