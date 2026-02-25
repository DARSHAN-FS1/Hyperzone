import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import '../widgets/animated_background.dart';
import '../widgets/neon_button.dart';
import '../theme.dart';
import '../services/auth_service.dart'; // <-- IMPORTANT

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool ob = true;

  String username = "";
  String password = "";

  // 👇 NEW: Test backend function
  Future<void> testBackend() async {
    final url = Uri.parse('http://localhost:8080/hello');

    try {
      final response = await http.get(url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Backend: ${response.body}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final auth = AuthService();
      final error = await auth.login(username, password);

      setState(() => loading = false);

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful ✅')),
        );
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
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
                    "Welcome to HYPERZONE",
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
                                TextFormField(
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Username or Email',
                                    hintStyle: const TextStyle(color: Colors.white70),
                                    filled: true,
                                    fillColor: Colors.white12,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (v) =>
                                      v == null || v.isEmpty ? 'Enter username' : null,
                                  onChanged: (v) => username = v,
                                ),

                                const SizedBox(height: 14),

                                TextFormField(
                                  obscureText: ob,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle: const TextStyle(color: Colors.white70),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        ob ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () => setState(() => ob = !ob),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white12,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (v) =>
                                      v == null || v.isEmpty ? 'Enter password' : null,
                                  onChanged: (v) => password = v,
                                ),

                                const SizedBox(height: 20),

                                SizedBox(
                                  width: double.infinity,
                                  child: NeonButton(
                                    text: 'Login',
                                    onPressed: _submit,
                                    isLoading: loading,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // 👇 ADDED: Test Backend Button
                                TextButton(
                                  onPressed: testBackend,
                                  child: const Text(
                                    "Test Backend",
                                    style: TextStyle(color: Colors.greenAccent),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                TextButton(
                                  onPressed: () => Navigator.of(context).pushNamed('/signup'),
                                  child: const Text(
                                    "Create account",
                                    style: TextStyle(color: Colors.white70),
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
