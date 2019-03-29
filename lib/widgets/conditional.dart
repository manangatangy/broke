
import 'package:flutter/widgets.dart';

/// ref: https://twitter.com/jcocaramos/status/1105290694992777216

typedef ConditionalContainerBuilder<S> = Widget Function(BuildContext context);

class ConditionalContainer<S> extends StatelessWidget {
  final Key containerKey;
  final bool condition;
  final ConditionalContainerBuilder<S> builder;

  ConditionalContainer({
    Key key,
    this.containerKey,
    @required this.condition,
    @required this.builder,
  })  : assert(builder != null),
        assert(condition != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => condition
      ? builder(context)
      : Container(key: containerKey ?? Key('conditionalContainer'));

}

Widget test(String userName) {
  return ConditionalContainer(
    key: Key('userName'),
    containerKey: Key('noUserRenderContainer'),
    condition: userName != null,
    builder: (context) => Text(userName),
  );
}
