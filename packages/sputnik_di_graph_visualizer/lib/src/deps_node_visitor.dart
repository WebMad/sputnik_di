import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:path/path.dart' as path;

class DepsNodeVisitor extends RecursiveElementVisitor<void> {
  final Map<String, Set<String>> deps = {};

  @override
  void visitClassElement(ClassElement element) {
    final isDepsNode = _isDepsNodeSubclass(element);

    if (!isDepsNode) {
      super.visitClassElement(element);
      return;
    }

    final dependencies = <String>{};

    final fields = element.fields;
    for (final field in fields) {
      final returnType = field.type;

      dependencies.addAll(_getDepsNodesByReturnType(returnType));
    }

    final methods = element.methods;
    for (final method in methods) {
      final returnType = method.returnType;

      dependencies.addAll(_getDepsNodesByReturnType(returnType));
    }

    final accessors = element.accessors;
    for (final accessor in accessors) {
      if (accessor.isGetter) {
        final returnType = accessor.returnType;

        dependencies.addAll(_getDepsNodesByReturnType(returnType));
      }
    }

    for (final dependency in dependencies) {
      print(' - $dependency');
    }

    if (deps[element.name] == null) {
      deps[element.name] = {};
    }

    deps[element.name]?.addAll(dependencies);

    super.visitClassElement(element);
  }

  Set<String> _getDepsNodesByReturnType(DartType returnType) {
    final res = <String>{};

    final returnElement = returnType.element;

    if (returnElement is ClassElement && _isDepsNodeSubclass(returnElement)) {
      res.add(returnElement.name);
    }

    if (returnType is ParameterizedType) {
      final typeArgs = returnType.typeArguments;
      for (final typeArg in typeArgs) {
        final elementTypeArg = typeArg.element;

        if (elementTypeArg is ClassElement &&
            _isDepsNodeSubclass(elementTypeArg)) {
          res.add(elementTypeArg.name);
        }
      }
    }

    return res;
  }

  bool _isDepsNodeSubclass(ClassElement element) {
    return element.allSupertypes.any((superType) {
      if (superType.element.name == 'DepsNode') {
        final packageInfo =
            path.toUri(superType.element.library.identifier).pathSegments.first;

        return packageInfo == 'package:sputnik_di';
      }

      return false;
    });
  }
}

class TestVisitor extends UnifyingTypeVisitor<void> {
  @override
  void visitDartType(DartType type) {}
}
