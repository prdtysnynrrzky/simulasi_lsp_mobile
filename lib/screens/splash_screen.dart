import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash-screen';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -20,
            left: -20,
            child: Image.asset(
              "assets/illustrations/vector2.png",
              width: 250,
            ),
          ),
          Positioned(
            bottom: -20,
            right: -20,
            child: Image.asset(
              "assets/illustrations/vector1.png",
              width: 250,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              "assets/illustrations/pattern1.png",
              width: 250,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              "assets/illustrations/pattern2.png",
              width: 250,
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
                const Spacer(),
                Image.asset(
                  'assets/logo/rpl.png',
                  width: 250,
                )
                    .animate()
                    .fadeIn(
                      delay: 200.ms,
                      curve: Curves.easeIn,
                      duration: 500.ms,
                    )
                    .shimmer(
                      delay: 700.ms,
                      duration: 3000.ms,
                      curve: Curves.easeInOut,
                    ),
                Text(
                  'Apk Sederhana via LSP',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: 200.ms,
                      curve: Curves.easeIn,
                      duration: 500.ms,
                    )
                    .shimmer(
                      delay: 700.ms,
                      duration: 2300.ms,
                      curve: Curves.easeInOut,
                    ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.only(bottom: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Developed by ",
                        style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        "ditya",
                        style: GoogleFonts.poppins(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ).animate().fadeIn(
                        delay: 200.ms,
                        curve: Curves.easeIn,
                        duration: 1000.ms,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
