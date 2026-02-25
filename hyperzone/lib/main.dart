import 'package:flutter/material.dart';

import 'widgets/animated_background.dart'; 
import 'theme.dart';
import 'package:url_strategy/url_strategy.dart';


import 'screens/splash_screen.dart';
import 'screens/landing_page.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';


import 'screens/home_screen.dart';
import 'screens/tournaments_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/my_hosted_tournaments_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/contact_us_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/host_tournament_screen.dart';
import 'screens/live_stream_screen.dart';
import 'models/tournament.dart';


import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'services/admin_api_service.dart';

void main() {
  setPathUrlStrategy();
  runApp(const HYPERZONEApp());
}


class HYPERZONEApp extends StatelessWidget {
  const HYPERZONEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HYPERZONE',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F18),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F1724),
          elevation: 0,
        ),
      ),

      
      initialRoute: "/",

      
      onGenerateRoute: (settings) {
  Widget page;

  switch (settings.name) {
    case "/":
      page = const SplashScreen();
      break;

    case "/landing":
      page = const LandingPage();
      break;

    case "/login":
      page = const LoginScreen();
      break;

    case "/signup":
      page = const SignupScreen();
      break;

    case "/home":
      page = const HomeScreen();
      break;

    case "/tournaments":
      page = const TournamentsScreen();
      break;

    case "/profile":
      page = const ProfileScreen();
      break;

    case "/admin":
      page = AdminDashboardScreen(
        api: AdminApiService(baseUrl: "http://localhost:8080/api"),
      );
      break;

    
    case "/host":
      page = HostTournamentScreen();
      break;

    
    case "/leaderboard":
      page = const LeaderboardScreen();
      break;

    
    case "/my-hosted":
      page = const MyHostedTournamentsScreen();
      break;

   case '/live':
  final t = settings.arguments as Tournament; 
  page = LiveStreamScreen(tournament: t);
  break;



    
    case "/wallet":
  final args = settings.arguments as Map<String, dynamic>?;

  final double balance =
      (args?['balance'] as double?) ?? 0.0;
  final List<Map<String, dynamic>> transactions =
      (args?['transactions'] as List<Map<String, dynamic>>?) ?? [];

  page = WalletScreen(
    balance: balance,
    transactions: transactions,
  );
  break;

    default:
      page = const SplashScreen();
  }

  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    // your transitionsBuilder + durations stay same
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
        reverseCurve: Curves.easeInQuart,
      );

      final slide = Tween<Offset>(
        begin: const Offset(0.08, 0.0),
        end: Offset.zero,
      ).animate(curved);

      final scale = Tween<double>(
        begin: 0.9,
        end: 1.0,
      ).animate(curved);

      final fade = curved;

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: ScaleTransition(
            scale: scale,
            child: child,
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 450),
    reverseTransitionDuration: const Duration(milliseconds: 350),
  );
},

    );
  }
}
