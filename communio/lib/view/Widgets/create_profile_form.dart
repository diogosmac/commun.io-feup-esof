import 'package:communio/view/Widgets/insert_email_field.dart';
import 'package:communio/view/Widgets/insert_name_field.dart';
import 'package:communio/view/Widgets/insert_new_password_field.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:toast/toast.dart';

class CreateProfileForm extends StatefulWidget {
  @override
  CreateProfileFormState createState() {
    return CreateProfileFormState();
  }
}

class CreateProfileFormState extends State<CreateProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _agreedToTOS = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 21),
          child: Text("Create an Account",
              style:
                  Theme.of(context).textTheme.body1.apply(fontWeightDelta: 3)),
        ),
        Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InsertNameField(nameController),
                  InsertEmailField(emailController),
                  InsertNewPasswordField(passwordController),
                  buildTOSCheckbox(),
                  buildSubmitButton(),
                  buildLoginLink(),
                ]))
      ],
    );
  }

  buildTOSCheckbox() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
          onTap: () => _setAgreedToTOS(!_agreedToTOS),
          child: Row(
            children: <Widget>[
              Checkbox(value: _agreedToTOS, onChanged: _setAgreedToTOS),
              Flexible(
                  child: Text(
                      'I agree to the Terms of Service and Privacy Policy',
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .apply(fontSizeDelta: -3)))
            ],
          )),
    );
  }

  submit() {
    if (!_agreedWithTerms()) {
      Toast.show('You must accept the TOS!', context);
      return;
    }

    if (_formKey.currentState.validate() && _agreedWithTerms()) {
      Toast.show('Processing Data', context);
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final testPassword = passwordController.text.trim();
      Logger().i("""Name: $name,
Email: $email,
Test Password: $testPassword,""");
    }
  }

  Widget buildSubmitButton() {
    final height = MediaQuery.of(context).size.width * 0.15;

    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Center(
            child: ButtonTheme(
                minWidth: MediaQuery.of(context).size.width,
                height: height,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(height * 0.25)),
                  textColor: Theme.of(context).canvasColor,
                  onPressed: () {
                    submit();
                  },
                  child: Text(
                    'Continue',
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .apply(fontSizeDelta: -5),
                  ),
                ))));
  }

  Widget buildLoginLink() {
    return Center(
      child: GestureDetector(
        child: Text(
          "Already have an account?",
          style: Theme.of(context)
              .textTheme
              .body2
              .apply(decoration: TextDecoration.underline, fontSizeDelta: -5),
        ),
        // onTap: ,
      ),
    );
  }

  bool _agreedWithTerms() {
    return _agreedToTOS;
  }

  void _setAgreedToTOS(bool value) {
    setState(() {
      _agreedToTOS = value;
    });
  }
}
