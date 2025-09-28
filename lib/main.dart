// main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:device_preview/device_preview.dart';

import 'screens/auth/splash_screen.dart';
import 'screens/dashboard/stats_screen.dart';
import 'screens/dashboard/home_dashboard.dart';
import 'screens/auth/sign_in.dart';
import 'screens/auth/sign_up.dart';
import 'screens/dashboard/account_settings_page.dart';
import 'screens/dashboard/bluetooth_page.dart';
import 'screens/dashboard/workouts_screen.dart';

void main() {
  runApp(DevicePreview(enabled: false, builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/signin': (context) => const SignIn(),
        '/signup': (context) => const SignUp(),
        '/home': (context) => const GoogleBottomBar(),
        '/bluetooth': (context) => const BluetoothHC05Page(),
      },
    );
  }
}

class GoogleBottomBar extends StatefulWidget {
  const GoogleBottomBar({super.key});

  @override
  State<GoogleBottomBar> createState() => _GoogleBottomBarState();
}

class _GoogleBottomBarState extends State<GoogleBottomBar> {
  int _selectedIndex = 0;

  final _pages = [
    const DashboardBody(),
    const WorkoutsScreen(),
    const HealthStatsPage(),
    const AccountSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: Image.asset('assets/images/logo_green.png', height: 40),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        actions: _selectedIndex == 0
            ? [
                Container(
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 233, 119),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () {
                      Navigator.pushNamed(context, '/bluetooth');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bluetooth,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Connect',
                            style: GoogleFonts.manrope(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(
            top: kToolbarHeight + 30,
            left: 20,
            right: 20,
          ),
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SalomonBottomBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedItemColor: const Color.fromARGB(
                255,
                0,
                233,
                119,
              ), // Green
              unselectedItemColor: const Color.fromARGB(
                255,
                0,
                233,
                119,
              ), // Green
              backgroundColor: Colors.transparent,
              itemShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              selectedColorOpacity: 1.0,
              items: [
                SalomonBottomBarItem(
                  icon: Icon(
                    Icons.home,
                    color: _selectedIndex == 0
                        ? const Color.fromARGB(255, 0, 233, 119)
                        : const Color.fromARGB(255, 0, 233, 119),
                    size: _selectedIndex == 0 ? 28 : 24,
                  ),
                  title: Text(
                    "Home",
                    style: GoogleFonts.manrope(
                      color: const Color.fromARGB(255, 0, 233, 119),
                      fontSize: 14,
                    ),
                  ),
                  selectedColor: Colors.white,
                ),
                SalomonBottomBarItem(
                  icon: Icon(
                    Icons.directions_run,
                    color: _selectedIndex == 1
                        ? const Color.fromARGB(255, 0, 233, 119)
                        : const Color.fromARGB(255, 0, 233, 119),
                    size: _selectedIndex == 1 ? 28 : 24,
                  ),
                  title: Text(
                    "Workouts",
                    style: GoogleFonts.manrope(
                      color: const Color.fromARGB(255, 0, 233, 119),
                      fontSize: 14,
                    ),
                  ),
                  selectedColor: Colors.white,
                ),
                SalomonBottomBarItem(
                  icon: Icon(
                    CupertinoIcons.flame,
                    color: _selectedIndex == 2
                        ? const Color.fromARGB(255, 0, 233, 119)
                        : const Color.fromARGB(255, 0, 233, 119),
                    size: _selectedIndex == 1 ? 28 : 24,
                  ),
                  title: Text(
                    "Stats",
                    style: GoogleFonts.manrope(
                      color: const Color.fromARGB(255, 0, 233, 119),
                      fontSize: 14,
                    ),
                  ),
                  selectedColor: Colors.white,
                ),
                SalomonBottomBarItem(
                  icon: Icon(
                    Icons.account_circle_outlined,
                    color: _selectedIndex == 3
                        ? const Color.fromARGB(255, 0, 233, 119)
                        : const Color.fromARGB(255, 0, 233, 119),
                    size: _selectedIndex == 2 ? 28 : 24,
                  ),
                  title: Text(
                    "Account",
                    style: GoogleFonts.manrope(
                      color: const Color.fromARGB(255, 0, 233, 119),
                      fontSize: 14,
                    ),
                  ),
                  selectedColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
