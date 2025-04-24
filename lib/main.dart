import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:quick_ahaar/config/firebase_config.dart';
import 'package:quick_ahaar/config/firebase_web_config.dart';
import 'package:quick_ahaar/providers/auth_provider.dart';
import 'package:quick_ahaar/providers/category_provider.dart';
import 'package:quick_ahaar/providers/cart_provider.dart';
import 'package:quick_ahaar/providers/order_provider.dart';
import 'package:quick_ahaar/providers/operating_hours_provider.dart';
import 'package:quick_ahaar/providers/theme_provider.dart';
import 'package:quick_ahaar/screens/login_screen.dart';
import 'package:quick_ahaar/screens/home_screen.dart';
import 'package:quick_ahaar/screens/verification_screen.dart';
import 'package:quick_ahaar/screens/categories_screen.dart';
import 'package:quick_ahaar/screens/profile_screen.dart';
import 'package:quick_ahaar/screens/cart_screen.dart';
import 'package:quick_ahaar/screens/order_history_screen.dart';
import 'package:quick_ahaar/screens/admin_login_screen.dart';
import 'package:quick_ahaar/screens/admin_register_screen.dart';
import 'package:quick_ahaar/screens/admin_dashboard_screen.dart';
import 'package:quick_ahaar/screens/auth_wrapper.dart';
import 'package:quick_ahaar/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (kIsWeb) {
      await FirebaseWebConfig.initializeFirebaseWeb();
    } else {
      await FirebaseConfig.initializeFirebase();
    }
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => OperatingHoursProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    return MaterialApp(
      title: 'QuickAhaar',
      theme: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/cart': (context) => const CartScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin-register': (context) => const AdminRegisterScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
      },
      builder: (context, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.watch<AuthProvider>().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final user = snapshot.data;
        final isEmailVerified = context.watch<AuthProvider>().isEmailVerified;
        final isAdmin = context.watch<AuthProvider>().isAdmin;
        
        if (user == null) {
          return const LoginScreen();
        }
        
        if (!isEmailVerified) {
          return VerificationScreen(
            email: user.email!,
            onResendVerification: () => context.read<AuthProvider>().resendEmailVerification(),
          );
        }
        
        if (isAdmin) {
          return const AdminDashboardScreen();
        }
        
        return const MainScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CategoriesScreen(),
    const OrderHistoryScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            ),
          ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
