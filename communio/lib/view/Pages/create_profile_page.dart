import 'package:communio/view/Pages/secondary_page_view.dart';
import 'package:communio/view/Widgets/create_profile_form.dart';
import 'package:flutter/material.dart';

class CreateProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SecondaryPageView(child: this.buildForm(context));
  }

  Widget buildForm(BuildContext context) {
    return ListView(
      shrinkWrap: false,
      children: <Widget>[
        CreateProfileForm(),
      ],
    );
  }
}
