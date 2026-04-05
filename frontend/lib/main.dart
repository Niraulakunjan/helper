import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/helper_dashboard_screen.dart';
import 'screens/helper_setup_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const HouseHelperApp(),
    ),
  );
}

class HouseHelperApp extends StatelessWidget {
  const HouseHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'House Helper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00D4AA),
          surface: const Color(0xFF0F2027),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F2027),
      ),
      home: const _SplashGate(),
    );
  }
}

class _SplashGate extends StatefulWidget {
  const _SplashGate();
  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final auth = context.read<AuthProvider>();
    await auth.tryAutoLogin();
    if (mounted) {
      Widget destination;
      if (auth.accessToken == null) {
        destination = const LoginScreen();
      } else if (auth.user?.role == 'helper') {
        destination = auth.user?.hasHelperProfile == true
            ? const HelperDashboardScreen()
            : const HelperSetupScreen();
      } else {
        destination = const HomeScreen();
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destination));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F2027),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA))),
    );
  }
}
