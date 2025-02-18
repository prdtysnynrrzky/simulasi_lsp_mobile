import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import "setting_screen.dart";
import 'transfer_screen.dart';
import '../providers/balance_provider.dart';
import '../widgets/costumAppBar.dart';
import '../widgets/cardMenu.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends ConsumerWidget {
  static const routeName = '/home-screen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saldo = ref.watch(balanceProvider);

    return Scaffold(
      appBar: customAppBar(
        noRek: '123456789',
        name: 'Rekayasa Perangkat Lunak',
        saldo: saldo.toString(),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/logo/rpl.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 19),
            child: Column(
              children: [
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      cardMenu(
                        icon: Icons.money,
                        label: 'Cek Saldo',
                        onTap: () {},
                      ).animate().fadeIn(
                            delay: 200.ms,
                            curve: Curves.easeIn,
                            duration: 500.ms,
                          ),
                      cardMenu(
                        icon: Icons.swap_horiz,
                        label: 'Transfer',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TransferScreen(),
                            ),
                          );
                        },
                      ).animate().fadeIn(
                            delay: 400.ms,
                            curve: Curves.easeIn,
                            duration: 500.ms,
                          ),
                      cardMenu(
                        icon: Icons.payment,
                        label: 'Pembayaran',
                      ).animate().fadeIn(
                            delay: 600.ms,
                            curve: Curves.easeIn,
                            duration: 500.ms,
                          ),
                      cardMenu(
                        icon: Icons.info_outline,
                        label: 'Informasi',
                      ).animate().fadeIn(
                            delay: 800.ms,
                            curve: Curves.easeIn,
                            duration: 500.ms,
                          ),
                      cardMenu(
                        icon: Icons.more_horiz,
                        label: 'Lainnya',
                      ).animate().fadeIn(
                            delay: 1000.ms,
                            curve: Curves.easeIn,
                            duration: 500.ms,
                          ),
                      cardMenu(
                        icon: Icons.settings,
                        label: 'Pengaturan',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingScreen(),
                            ),
                          );
                        },
                      ).animate().fadeIn(
                            delay: 1200.ms,
                            curve: Curves.easeIn,
                            duration: 500.ms,
                          ),
                    ],
                  ),
                )
                    .animate(
                      onComplete: (controller) => controller.repeat(),
                    )
                    .shimmer(
                      delay: 3000.ms,
                      duration: 3000.ms,
                      curve: Curves.easeInOut,
                    ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: Colors.blue,
        child: Text(
          'Rekayasa Perangkat Lunak',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
