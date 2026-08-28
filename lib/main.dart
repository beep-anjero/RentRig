import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentrig/utils/app_colors.dart';
import 'package:rentrig/screens/add_tools_screen.dart';
import 'package:rentrig/screens/borrowed_tools_screen.dart';
import 'package:rentrig/screens/chat_screen.dart';
import 'package:rentrig/screens/edit_profile_screen.dart';
import 'package:rentrig/screens/home_screen.dart';
import 'package:rentrig/screens/log_in_screen.dart';
import 'package:rentrig/screens/my_tools_screen.dart';
import 'package:rentrig/screens/pending_requests_screen.dart';
import 'package:rentrig/screens/profile_screen.dart';
import 'package:rentrig/screens/sign_up_screen.dart';
import 'package:rentrig/screens/splash_screen.dart';
import 'package:rentrig/screens/tool_details_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData.dark().textTheme,
        ),
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accentSecondary,
          surface: AppColors.surface,
          background: AppColors.background,
          onBackground: AppColors.white,
          onSurface: AppColors.white,
        ),
        useMaterial3: true,
      ),
      title: 'rentrig',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/log_in': (context) => const LogInScreen(),
        '/sign_up': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/add_tool': (context) => const AddToolScreen(),
        '/profile': (context) => ProfileScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/borrowed_tools': (context) => const BorrowedToolsScreen(),
        '/my_tools': (context) => const MyToolsScreen(),
        '/pending_requests': (context) => const PendingRequestsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/tool_detail') {
          final tool = settings.arguments;
          return MaterialPageRoute(
            builder: (context) => ToolDetailScreen(tool: tool),
          );
        } else if (settings.name == '/chat') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null) {
            return MaterialPageRoute(
              builder: (context) => ChatScreen(
                rentalId: args['rentalId'] ?? '',
                toolName: args['toolName'] ?? 'Rental Item',
                otherPartyName: args['otherPartyName'] ?? 'Member',
                otherPartyEmail: args['otherPartyEmail'] ?? '',
              ),
            );
          }
        }
        return null;
      },
    );
  }
}

