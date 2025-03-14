import 'package:flutter/material.dart';
import 'package:wisteria/app/constants.dart';
import 'package:wisteria/app/app_controller.dart';
import 'package:wisteria/app/views/profile/views/logged_in_view.dart';
import 'package:wisteria/app/views/profile/views/not_logged_in_view.dart';
import 'package:wisteria/app/views/profile/utils/profile_view_controller.dart';
import '../../../widgets/wisteria_text.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final controller = ProfileViewController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryWhite,
      body: profileView(),
    );
  }

  Widget profileView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),

        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: WisteriaText(
            text: "profile", 
            color: primaryTextColor,
            size: 24,
          ),
        ),

        const SizedBox(height: 28),

        profileBox(),
      ],
    );
  }

  Widget profileBox() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height - 230,
      child: profile()
    );
  }

  Widget profile() {
    return AppController.instance.user == null ? 
    NotLoggedInView(
      update: () {
        setState(() {});
      },
    ) : LoggedInView(
      update: () {
        setState(() {});
      },
    );
  }
}