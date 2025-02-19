
import 'package:flutter/material.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_images.dart';
import '../../../../data/services/auth/auth_service.dart';
import '../../../components/gradient_background/gradient_background.dart';
import '../../../components/button/custom_button.dart';
import '../../dashboard/dashboard_screen.dart';
import '../registration/register_screen.dart';
import '../widget/auth_text_input.dart';
import '../widget/forgot_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _login() async {
    final user = await _authService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Login gagal. Periksa email dan password.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: Dimensions.space30,
              ),
              Image.asset(MyImages.appLogoBanner),
              const SizedBox(height: Dimensions.space50),
              AuthTextInput(controller: emailController, hintText: "Email"),
              const SizedBox(height: Dimensions.space20),
              AuthTextInput(
                  controller: passwordController,
                  hintText: "Password",
                  isPassword: true),
              const SizedBox(height: Dimensions.space15),
              const ForgotButton(),
              const SizedBox(height: Dimensions.space30),
              CustomButton(
                text: "Masuk",
                onPressed: _login,
              ),
              const SizedBox(height: Dimensions.space20),
              CustomButton(
                text: "Daftar",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                color: Colors.white,
                textColor: MyColor.secondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
