import 'package:flutter/material.dart';

//TextStyle(
//color: Colors.black87,
//fontSize: 18.0,
//fontWeight: FontWeight.w400,
//);

const TextStyle TextStyleFlatButton = const TextStyle(
  color: Colors.black87,
  fontSize: 18.0,
  fontWeight: FontWeight.w400,
);

const TextStyle TextStyleRaisedButton = const TextStyle(
//  color: Colors.black87,
  fontSize: 20.0,
//  fontWeight: FontWeight.w400,
);

FlatButton appFlatButton({String data, @required VoidCallback onPressed}) {
  return FlatButton(
    onPressed: onPressed,
    child: Text(
      data,
      style: TextStyleFlatButton,
    ),
  );
}

RaisedButton appRaisedButton({
  String data,
  @required VoidCallback onPressed,
}) {
  return RaisedButton(
    elevation: 5.0,
    onPressed: onPressed,
    child: Text(
      data,
      style: TextStyleRaisedButton,
    ),
    // shape and color are set via MaterialApp.theme.themeData
  );
}

class ButtonFlat extends StatelessWidget {
  final Widget child;

  ButtonFlat({
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    ///     final ThemeData theme = Theme.of(context);
    ///     return Theme(
    ///       data: theme.copyWith(
    ///         textTheme: theme.textTheme.copyWith(
    ///           title: theme.textTheme.title.copyWith(
    ///             color: titleColor,
    ///           ),
    ///         ),
    ///       ),
    ///       child: child,
    ///     );
    ///   }
    return Container();
  }
}

ThemeData buildTheme() {
  // We're going to define all of our font styles
  // in this method:
  TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      headline: base.headline.copyWith(
        fontFamily: 'Merriweather',
        fontSize: 40.0,
        color: const Color(0xFF807A6B),
      ),
      // New code:
      // Used for the recipes' title:
      title: base.title.copyWith(
        fontFamily: 'Merriweather',
        fontSize: 15.0,
        color: const Color(0xFF807A6B),
      ),
      // Used for the recipes' duration:
      caption: base.caption.copyWith(
        // Used in unselected BottomNavigationBarItem text and icon
        color: const Color(0xFF33C5AF),
        fontSize: 15.0,
      ),
      // Used for default TextFormField style
      subhead: base.subhead.copyWith(
        fontSize: 20.0,
      ),
    );
  }

  // We want to override a default light blue theme.
  final ThemeData base = ThemeData.light();

  AppBarTheme _buildAppBarTheme(AppBarTheme appBarBase) {
    return appBarBase.copyWith(
      textTheme: base.primaryTextTheme.copyWith(
          title: base.primaryTextTheme.title.copyWith(
        color: Color(0xff223344),
      )),
//      color: const Color(0xFF223333),
    );
  }

  // And apply changes on it:
  ThemeData old = base.copyWith(
    appBarTheme: _buildAppBarTheme(base.appBarTheme),
    textTheme: _buildTextTheme(base.textTheme),
    primaryColor: const Color(0xFFFFF8E1),
    // Appbar background
    indicatorColor: const Color(0xFF807A6B),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    accentColor: const Color(0xFFFFF8E1),
    // CircularProgressIndicator color
    iconTheme: IconThemeData(
      color: const Color(0xFFCCC5AF),
      size: 20.0,
    ),
    buttonColor: Colors.white,

    buttonTheme: ButtonThemeData(
      buttonColor: Colors.blue, // Body color for raisedButton
      textTheme: ButtonTextTheme.primary,
//      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
//      color: Colors.blue,
    ),
  );

  return ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blueGrey,
    accentColor: Colors.greenAccent,
    accentColorBrightness: Brightness.light,
  );
}

// https://developers.google.com/identity/branding-guidelines
// https://fonts.google.com/specimen/Roboto
// https://fonts.google.com/specimen/Merriweather
