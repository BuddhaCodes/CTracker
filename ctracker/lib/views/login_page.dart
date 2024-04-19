import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/pocketbase_provider.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class LoginPage extends StatelessWidget {
  Function(bool) checkStatus;
  LoginPage({super.key, required this.checkStatus});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final PocketBase pb = locator<PocketBase>();

  Future<void> _login(BuildContext context) async {
    MyLocalizations? localizations = MyLocalizations.of(context);
    try {
      final authData = await pb.collection('users').authWithPassword(
            usernameController.text,
            passwordController.text,
          );

      pb.authStore.save(authData.token, authData.record);

      checkStatus(pb.authStore.isValid);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.translate('failedlogin')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    MyLocalizations? localizations = MyLocalizations.of(context);
    return Scaffold(
      backgroundColor: ColorP.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              // logo
              const Icon(
                Icons.lock,
                size: 100,
              ),

              const SizedBox(height: 50),

              Text(
                localizations.translate('welcome'),
                style: const TextStyle(
                  color: ColorP.textColorSubtitle,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              MyTextField(
                controller: usernameController,
                hintText: localizations.translate('username'),
                obscureText: false,
              ),

              const SizedBox(height: 10),

              MyTextField(
                controller: passwordController,
                hintText: localizations.translate('password'),
                obscureText: true,
              ),

              const SizedBox(height: 10),

              // const Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 25.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.end,
              //     children: [
              //       Text(
              //         'Forgot Password?',
              //         style: TextStyle(color: ColorP.textColorSubtitle),
              //       ),
              //     ],
              //   ),
              // ),

              const SizedBox(height: 25),

              MyButton(
                onTap: () => _login(context),
              ),

              const SizedBox(height: 50),

              // const Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       'Not a member?',
              //       style: TextStyle(color: ColorP.textColorSubtitle),
              //     ),
              //     SizedBox(width: 4),
              //     Text(
              //       'Register now',
              //       style: TextStyle(
              //         color: Colors.blue,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  final Function()? onTap;

  const MyButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            "Sign In",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
          filled: true,
          hintText: hintText,
          hintStyle: const TextStyle(color: ColorP.textColor),
          fillColor: ColorP.cardBackground,
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
      ),
    );
  }
}

class SquareTile extends StatelessWidget {
  final String imagePath;
  const SquareTile({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      child: Image.asset(
        imagePath,
        height: 40,
      ),
    );
  }
}
