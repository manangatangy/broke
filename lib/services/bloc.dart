

import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';

class Bloc extends Model {
  static Bloc of(BuildContext context) => ScopedModel.of<Bloc>(context);


}
