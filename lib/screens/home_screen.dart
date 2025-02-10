import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/balance_provider.dart';
import '../widgets/appBar.dart';
import '../widgets/cardMenu.dart';
import "setting_screen.dart";
import 'transfer_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saldo = ref.watch(balanceProvider);

    return Scaffold(
      appBar: cAppBar(
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
                'assets/images/smkpgriwlingi.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                      ),
                      cardMenu(
                        icon: Icons.payment,
                        label: 'Pembayaran',
                      ),
                      cardMenu(
                        icon: Icons.info_outline,
                        label: 'Informasi',
                      ),
                      cardMenu(
                        icon: Icons.more_horiz,
                        label: 'Lainnya',
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
                      ),
                    ],
                  ),
                ),
              ),
              Container(
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
            ],
          ),
        ],
      ),
    );
  }
}
