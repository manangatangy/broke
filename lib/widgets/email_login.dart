import 'package:broke/models/sign_in.dart';
import 'package:broke/widgets/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailLoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _EmailLoginScreenState();
}

enum FormMode { LOGIN, SIGNUP }

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _formKey = new GlobalKey<FormState>();
  SignInModel _signInModel;

  String _email;
  String _password;
  String _errorMessage;

  FormMode _formMode = FormMode.LOGIN;
  bool _validatePassword;
  bool _isIos;
  bool _isLoading;

  bool get isLogin => (_formMode == FormMode.LOGIN);

  @override
  void initState() {
    super.initState();
    _errorMessage = "";
    _isLoading = false;
    _validatePassword = true;
    _signInModel = SignInModel.of(context);
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('BROKE Debt Recorder'),
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
            progressIndicator(),
          ],
        ));
  }

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
      _validatePassword = true;
    });
    if (_validateAndSave()) {
      try {
        if (_formMode == FormMode.SIGNUP) {
          FirebaseUser user = await _signInModel.signUpWithEmail(_email, _password);
          _signInModel.sendEmailVerification(user);
          showDismissableDialog(
            'Verify your account',
            'Link to verify account has been sent to your email',
          );

          print('Signed up and emailed verification request');
        } else {
          bool signedIn = await _signInModel.signInWithEmail(_email, _password);
          if (signedIn) {
            // From: https://medium.com/flutter-community/flutter-push-pop-push-1bb718b13c31
            // Remove "login" and current/email routes, and replace with "/"
            Navigator.of(context).pushNamedAndRemoveUntil("/", (Route<dynamic> route) => false);
          } else {
            _showSignInFailedDialog();
          }
          // TODO what if failed to sign in ?
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.details;
          } else
            _errorMessage = e.message;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _changeFromMode(FormMode formMode) {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = formMode;
    });
  }

  void _forgottenPassword() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
      _validatePassword = false;
    });
    if (_validateAndSave()) {
      try {
        await _signInModel.resetEmailPassword(_email);
        showDismissableDialog(
          'Reset your Password',
          'Link to reset account password has been sent to your email',
        );
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.details;
          } else
            _errorMessage = e.message;
        });
      }
    }
  }

  Widget progressIndicator(){
    if (_isLoading) {
      print("_showCircularProgress loading");
      return Center(child: CircularProgressIndicator(backgroundColor: Colors.blueGrey,));
    } return Container(height: 0.0, width: 0.0,);

  }

  void _showVerifyEmxailSentDialog(String label) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(label),
          content: new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                _changeFromMode(FormMode.LOGIN);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showDismissableDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(message),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                _changeFromMode(FormMode.LOGIN);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSignInFailedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Email sign in"),
          content: new Text("Error occurred during sign in"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showBody() {
    return Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              Hero(
                tag: 'hero',
                child: Container(
                  height: 200,
                  width: 200,
                  margin: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                  child: Image.asset('assets/empty-pockets.png'),
                ),
              ),
              emailInputField(),
              passwordInputField(),
              Padding(
                padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
                child: SizedBox(
                  height: 40,
                  child: appRaisedButton(
                    onPressed: _validateAndSubmit,
                    data: isLogin ? 'Login' : 'Create account',
                  ),
                ),
              ),
              appFlatButton(
                onPressed: () => _changeFromMode(isLogin ? FormMode.SIGNUP : FormMode.LOGIN),
                data: isLogin ? 'Create an account' : 'Have an account? Sign in',
              ),
              appFlatButton(
                onPressed: _forgottenPassword,
                data: 'Forgotten password?',
              ),
              errorMessageText(),
            ],
          ),
        ));
  }

  Widget errorMessageText() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 16.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget emailInputField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        // defaults to subhead text style
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value,
      ),
    );
  }

  Widget passwordInputField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) =>
            _validatePassword && value.isEmpty ? 'Password can\'t be empty'
            : (!_validatePassword && value.isNotEmpty ? 'Password not required for reset' : null),
        onSaved: (value) => _password = value,
      ),
    );
  }

}
