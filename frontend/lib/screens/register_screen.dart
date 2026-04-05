import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'user';
  String? _error;
  bool _obscure = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    try {
      await auth.register(_usernameCtrl.text.trim(), _emailCtrl.text.trim(), _phoneCtrl.text.trim(), _passwordCtrl.text, _role);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registered! Please login.'), backgroundColor: Color(0xFF00D4AA)));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Icon(Icons.person_add, size: 60, color: Color(0xFF00D4AA)),
                const SizedBox(height: 12),
                const Text('Create Account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 28),
                Card(
                  color: Colors.white.withOpacity(0.07),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (_error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                              child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                            ),
                            const SizedBox(height: 12),
                          ],
                          _field(_usernameCtrl, 'Username', Icons.person),
                          const SizedBox(height: 12),
                          _field(_emailCtrl, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 12),
                          _field(_phoneCtrl, 'Phone', Icons.phone, keyboardType: TextInputType.phone, required: false),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            style: const TextStyle(color: Colors.white),
                            decoration: _deco('Password', Icons.lock, suffix: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            )),
                            validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text('I am a:', style: TextStyle(color: Colors.white70)),
                              const SizedBox(width: 12),
                              _roleChip('user', 'User'),
                              const SizedBox(width: 8),
                              _roleChip('helper', 'Helper'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: auth.loading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00D4AA),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: auth.loading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Already have an account? Login', style: TextStyle(color: Color(0xFF00D4AA))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleChip(String value, String label) => ChoiceChip(
    label: Text(label),
    selected: _role == value,
    onSelected: (_) => setState(() => _role = value),
    selectedColor: const Color(0xFF00D4AA),
    backgroundColor: Colors.white12,
    labelStyle: TextStyle(color: _role == value ? Colors.white : Colors.white54),
  );

  TextFormField _field(TextEditingController ctrl, String label, IconData icon, {TextInputType? keyboardType, bool required = true}) => TextFormField(
    controller: ctrl, keyboardType: keyboardType,
    style: const TextStyle(color: Colors.white),
    decoration: _deco(label, icon),
    validator: required ? (v) => (v == null || v.isEmpty) ? 'Required' : null : null,
  );

  InputDecoration _deco(String label, IconData icon, {Widget? suffix}) => InputDecoration(
    labelText: label, labelStyle: const TextStyle(color: Colors.white70),
    prefixIcon: Icon(icon, color: const Color(0xFF00D4AA)), suffixIcon: suffix,
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00D4AA))),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
    errorStyle: const TextStyle(color: Colors.redAccent),
    filled: true, fillColor: Colors.white.withOpacity(0.05),
  );
}
