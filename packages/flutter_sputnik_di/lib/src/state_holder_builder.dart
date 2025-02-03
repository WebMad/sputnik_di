import 'package:flutter/material.dart';
import 'package:sputnik_di/sputnik_di.dart';

class StateHolderBuilder<Holder extends StateHolder<T>, T>
    extends StatelessWidget {
  final Widget Function(BuildContext context, T state) builder;
  final Holder holder;

  const StateHolderBuilder({
    required this.builder,
    required this.holder,
    super.key,
  });

  @override
  Widget build(BuildContext context) => StreamBuilder<T>(
        initialData: holder.state,
        stream: holder.stream,
        builder: (context, snapshot) => builder(context, snapshot.requireData),
      );
}
