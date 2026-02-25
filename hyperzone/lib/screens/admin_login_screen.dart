import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart'; // Keep this import for the build method to work

/// Professional Admin Login Screen for Hyperzone
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // 🔐 FIXED ADMIN CREDENTIALS
  final String _fixedUsername = "darshan1";
  final String _fixedPassword = "1234";

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 350)); // small UX delay

    final user = _userController.text.trim();
    final pass = _passController.text.trim();

    if (user == _fixedUsername && pass == _fixedPassword) {
      if (!mounted) return;
      
      // 🔥 FIX APPLIED HERE: Use pushReplacementNamed to update the URL to #/admin
      Navigator.pushReplacementNamed(
        context,
        '/admin', 
      );
      
    } else {
      setState(() {
        _errorMessage = "Invalid admin credentials. Please try again.";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Same style structure as your main login
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF020617),
              Color(0xFF1D2035),
              Color(0xFF3B1F54),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _buildCard(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF020617).withOpacity(0.96),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 40,
            offset: const Offset(0, 24),
            spreadRadius: -18,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF4B5563).withOpacity(0.6),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top icon + title
          Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00C7FF),
                      Color(0xFF6366F1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Admin Portal",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Restricted access • Hyperzone Control Panel",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Username input
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Admin username",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _userController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter admin username",
              hintStyle: const TextStyle(color: Color(0xFF6B7280)),
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF9CA3AF),
              ),
              filled: true,
              fillColor: const Color(0xFF020617),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF374151),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF00C7FF),
                  width: 1.3,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Password input
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Password",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _passController,
            style: const TextStyle(color: Colors.white),
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: "Enter admin password",
              hintStyle: const TextStyle(color: Color(0xFF6B7280)),
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF9CA3AF),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF9CA3AF),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              filled: true,
              fillColor: const Color(0xFF020617),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF374151),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF00C7FF),
                  width: 1.3,
                ),
              ),
            ),
          ),

          // Error text
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 16,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 22),

          // Login button (gradient)
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFFEC4899),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        "Login as Admin",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Small footer / back link
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Back to Hyperzone",
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}