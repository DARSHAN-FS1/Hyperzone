import 'package:flutter/material.dart';
import '../widgets/animated_background.dart';
import '../widgets/neon_button.dart';
import '../theme.dart';
import '../services/auth_service.dart'; // <--- IMPORTANT

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool ob = true;

  String username = "";
  String email = "";
  String password = "";

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final auth = AuthService();
      final error = await auth.signup(username, email, password);

      setState(() => loading = false);

      if (error == null) {
        // success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created — please login')),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        // backend sent error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth < 600 ? screenWidth * 0.9 : 480.0;

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo.jpg', height: 80),
                  const SizedBox(height: 18),

                  Text(
                    "Join HYPERZONE",
                    style: headingStyle,
                  ),

                  const SizedBox(height: 18),

                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: formWidth,
                        minWidth: 260,
                      ),
                      child: Card(
                        color: AppColors.cardBg.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // username
                                TextFormField(
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Username',
                                    hintStyle:
                                        const TextStyle(color: Colors.white70),
                                    filled: true,
                                    fillColor: Colors.white12,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (v) =>
                                      v == null || v.isEmpty ? 'Enter username' : null,
                                  onChanged: (v) => username = v,
                                ),

                                const SizedBox(height: 12),

                                // email
                                TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Email',
                                    hintStyle:
                                        const TextStyle(color: Colors.white70),
                                    filled: true,
                                    fillColor: Colors.white12,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Enter email';
                                    }
                                    final emailRegex =
                                        RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                    if (!emailRegex.hasMatch(v)) {
                                      return 'Enter valid email';
                                    }
                                    return null;
                                  },
                                  onChanged: (v) => email = v,
                                ),

                                const SizedBox(height: 12),

                                // password
                                TextFormField(
                                  obscureText: ob,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Password (min 4 chars)',
                                    hintStyle:
                                        const TextStyle(color: Colors.white70),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        ob
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () =>
                                          setState(() => ob = !ob),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white12,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Enter password';
                                    }
                                    if (v.length < 4) {
                                      return 'Password too short';
                                    }
                                    return null;
                                  },
                                  onChanged: (v) => password = v,
                                ),

                                const SizedBox(height: 18),

                                SizedBox(
                                  width: double.infinity,
                                  child: NeonButton(
                                    text: 'Create account',
                                    onPressed: _submit,
                                    isLoading: loading,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushReplacementNamed('/login');
                                  },
                                  child: const Text(
                                    "Already have an account? Login",
                                    style: TextStyle(color: Colors.white70),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
