// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/balance_provider.dart';
import '../widgets/appBar.dart';
import '../widgets/button.dart';
import 'home_screen.dart';

class ReceiptScreen extends ConsumerWidget {
  final String tanggal;
  final String jenis;
  final String pengirim;
  final String penerima;
  final String noRekening;
  final int nominal;
  final String berita;

  const ReceiptScreen({
    super.key,
    required this.tanggal,
    required this.jenis,
    required this.pengirim,
    required this.penerima,
    required this.noRekening,
    required this.nominal,
    required this.berita,
  });

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
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bukti Transaksi',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 25),
                ),
                const SizedBox(height: 20),
                infoRow("Tanggal Transaksi", tanggal),
                infoRow("Jenis Transaksi", jenis),
                infoRow("Nama Pengirim", pengirim),
                infoRow("Nama Penerima", penerima),
                infoRow("No Rek. Tujuan", noRekening),
                infoRow("Nominal Transfer", 'Rp$nominal'),
                infoRow("Berita", berita),
                const SizedBox(height: 20),
                cButton(
                  text: 'Cetak & Kembali',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  color: Colors.lightBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow(String title, String value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
        const Divider(color: Colors.grey),
      ],
    );
  }
}
