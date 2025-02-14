abstract class DepsNodeExport {
  String export();
}

class DepsNodesToMermaid implements DepsNodeExport {
  final Map<String, Set<String>> _deps;

  const DepsNodesToMermaid(this._deps);

  @override
  String export() {
    final buff = StringBuffer('flowchart\n');

    final entries = _deps.entries;

    for (final entry in entries) {
      buff.write('\t${entry.key}((${entry.key}))\n');
      final dependencies = entry.value;

      for (final dependency in dependencies) {
        buff.write('\t${entry.key} --> $dependency\n');
      }
    }

    return buff.toString();
  }
}

class DepsNodesToPlantUml implements DepsNodeExport {
  final Map<String, Set<String>> _deps;

  const DepsNodesToPlantUml(this._deps);

  @override
  String export() {
    final buff = StringBuffer('@startuml\n');

    final entries = _deps.entries;

    for (final entry in entries) {
      final dependencies = entry.value;

      for (final dependency in dependencies) {
        buff.write('\t[${entry.key}] --> [$dependency]\n');
      }
    }

    buff.write('@enduml');

    return buff.toString();
  }
}
