import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'screens/login_screen.dart';
import 'screens/user/user_home_screen.dart';
import 'screens/user/discovery_screen.dart';
import 'screens/user/notifications_screen.dart';
import 'screens/user/saved_places_screen.dart';
import 'screens/user/booking_history_screen.dart';
import 'screens/provider/provider_home_screen.dart';
import 'screens/provider/analytics_screen.dart';
import 'screens/provider/profit_map_screen.dart';
import 'screens/common/profile_screen.dart';
import 'services/firebase_auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    // TLHC (false) is the correct renderer for Android 14+.
    // Hybrid Composition (true) causes a blank/black map on newer devices.
    mapsImplementation.useAndroidViewSurface = false;
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// ─────────────────────────────────────────────────────────────────────────────
//  App root
// ─────────────────────────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Map2Market',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4361EE)),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4361EE),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Auth gate
// ─────────────────────────────────────────────────────────────────────────────
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) return const MainContainer();
        return const LoginScreen();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Main shell
// ─────────────────────────────────────────────────────────────────────────────
class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;
  String? _userRole;
  bool _isLoading = true;
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      final role = await _authService.getUserRole(user.uid);
      if (mounted) {
        setState(() {
          _userRole = role;
          _isLoading = false;
        });
      }
    }
  }

  List<Widget> _getUserScreens() => [
        const UserHomeScreen(),
        const DiscoveryScreen(),
        const BookingHistoryScreen(),
        const ProfileScreen(),
      ];

  List<Widget> _getProviderScreens() => [
        const ProviderHomeScreen(),
        const ProfitMapScreen(),
        const AnalyticsScreen(),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final isProvider = _userRole == 'SERVICE_PROVIDER';
    final screens =
        isProvider ? _getProviderScreens() : _getUserScreens();

    final providerItems = const [
      _NavItem(icon: Icons.dashboard_rounded,       label: 'Dashboard'),
      _NavItem(icon: Icons.location_on_rounded,     label: 'Opportunities'),
      _NavItem(icon: Icons.analytics_rounded,       label: 'Analytics'),
      _NavItem(icon: Icons.person_rounded,          label: 'Account'),
    ];

    final userItems = const [
      _NavItem(icon: Icons.map_rounded,             label: 'Explore'),
      _NavItem(icon: Icons.explore_rounded,         label: 'Discover'),
      _NavItem(icon: Icons.calendar_month_rounded,  label: 'Bookings'),
      _NavItem(icon: Icons.person_rounded,          label: 'Profile'),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(isProvider ? 'Provider Hub' : 'User Portal'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await _authService.logoutUser(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: _FloatingNavBar(
        selectedIndex: _selectedIndex,
        items: isProvider ? providerItems : userItems,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Nav item data model
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ─────────────────────────────────────────────────────────────────────────────
//  Premium floating bottom nav bar
// ─────────────────────────────────────────────────────────────────────────────
class _FloatingNavBar extends StatefulWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  State<_FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<_FloatingNavBar> {
  late List<bool> _pressed;

  @override
  void initState() {
    super.initState();
    _pressed = List.filled(widget.items.length, false);
  }

  @override
  void didUpdateWidget(_FloatingNavBar old) {
    super.didUpdateWidget(old);
    if (widget.items.length != old.items.length) {
      _pressed = List.filled(widget.items.length, false);
    }
  }

  void _down(int i) => setState(() => _pressed[i] = true);
  void _up(int i) {
    setState(() => _pressed[i] = false);
    widget.onTap(i);
  }
  void _cancel(int i) => setState(() => _pressed[i] = false);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF0F0E1A), // deep navy
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFF4361EE).withOpacity(0.18),
                blurRadius: 48,
                spreadRadius: -6,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(widget.items.length, (i) {
              final item = widget.items[i];
              final active = widget.selectedIndex == i;

              return GestureDetector(
                onTapDown: (_) => _down(i),
                onTapUp: (_) => _up(i),
                onTapCancel: () => _cancel(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedScale(
                  scale: _pressed[i] ? 0.85 : 1.0,
                  duration: const Duration(milliseconds: 110),
                  child: SizedBox(
                    width: 70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── icon pill ──────────────────────────────────
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          width: active ? 54 : 42,
                          height: active ? 42 : 36,
                          decoration: active
                              ? BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4361EE),
                                      Color(0xFF7B2FBE),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4361EE)
                                          .withOpacity(0.60),
                                      blurRadius: 18,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                )
                              : null,
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 240),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                item.icon,
                                key: ValueKey(active),
                                size: active ? 26 : 22,
                                color: active
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.38),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // ── label ──────────────────────────────────────
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 240),
                          style: TextStyle(
                            fontSize: active ? 10.5 : 9.5,
                            fontWeight: active
                                ? FontWeight.w800
                                : FontWeight.w400,
                            color: active
                                ? const Color(0xFF7B9FFF)
                                : Colors.white.withOpacity(0.38),
                            letterSpacing: active ? 0.4 : 0.0,
                          ),
                          child: Text(item.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
