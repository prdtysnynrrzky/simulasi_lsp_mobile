// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simulasi_lsp_praditya/services/text_to_speech_service.dart';
import 'receipt_screen.dart';
import '../helpers/currency_format.dart';
import '../widgets/costumAppBar.dart';
import '../providers/balance_provider.dart';
import '../helpers/date_format.dart';

class TransferScreen extends ConsumerStatefulWidget {
  static const routeName = '/transfer-screen';
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController noRekController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController beritaController = TextEditingController();

  void transferSaldo() {
    if (!_formKey.currentState!.validate()) {
      TextToSpeechService().queue('Mohon lengkapi semua data dengan benar.');
      return;
    }

    final noRek = noRekController.text.trim();
    final name = nameController.text.trim();
    final nominal = int.tryParse(nominalController.text.trim()) ?? 0;
    final berita = beritaController.text.trim();
    final saldoNotifier = ref.read(balanceProvider.notifier);
    final saldo = ref.read(balanceProvider);

    if (nominal > saldo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo tidak mencukupi!'),
          backgroundColor: Colors.red,
        ),
      );
      TextToSpeechService().queue('Saldo tidak mencukupi!');
      return;
    }

    saldoNotifier.update((state) => state - nominal);
    TextToSpeechService().queue('Transfer ke $name berhasil.');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptScreen(
          tanggal: DateFormatHelper.format(DateTime.now()),
          jenis: "Transfer",
          pengirim: "Rekayasa",
          penerima: name,
          noRekening: noRek,
          nominal: nominal,
          berita: berita,
        ),
      ),
    ).then(
      (_) {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'Saldo Anda: ${CurrencyFormat.toRupiah(int.parse(saldo.toString()))}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            'Transfer',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.blue,
                            ),
                          ).animate().fadeIn(
                                delay: 200.ms,
                                curve: Curves.easeIn,
                                duration: 500.ms,
                              ),
                          const Divider().animate().fadeIn(
                                delay: 200.ms,
                                curve: Curves.easeIn,
                                duration: 500.ms,
                              ),
                          const SizedBox(height: 24),
                          Animate(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  TextToSpeechService().queue(
                                      'Nomor rekening tujuan wajib diisi.');
                                  return 'Nomor rekening tujuan wajib diisi';
                                }
                                return null;
                              },
                              onFieldSubmitted: (value) {
                                transferSaldo();
                              },
                              controller: noRekController,
                              style: GoogleFonts.poppins(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 19),
                                labelText: "No Rekening Tujuan",
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ).animate().fadeIn(
                                  delay: 200.ms,
                                  curve: Curves.easeIn,
                                  duration: 500.ms,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Animate(
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  TextToSpeechService()
                                      .queue('Nama penerima wajib diisi.');
                                  return 'Nama penerima wajib diisi';
                                }
                                return null;
                              },
                              onFieldSubmitted: (value) {
                                transferSaldo();
                              },
                              controller: nameController,
                              style: GoogleFonts.poppins(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 19),
                                labelText: "Nama Penerima",
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ).animate().fadeIn(
                                  delay: 400.ms,
                                  curve: Curves.easeIn,
                                  duration: 500.ms,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Animate(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                final nominal = int.tryParse(value ?? '');
                                if (nominal == null || nominal <= 5000) {
                                  TextToSpeechService().queue(
                                      'Nominal transfer harus lebih dari 5000.');
                                  return 'Nominal transfer harus lebih dari 5000';
                                }
                                return null;
                              },
                              onFieldSubmitted: (value) {
                                transferSaldo();
                              },
                              controller: nominalController,
                              style: GoogleFonts.poppins(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 19),
                                labelText: "Nominal Transfer",
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ).animate().fadeIn(
                                  delay: 600.ms,
                                  curve: Curves.easeIn,
                                  duration: 500.ms,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Animate(
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value != null && value.length > 15) {
                                  TextToSpeechService()
                                      .queue('Berita maksimal 15 karakter.');
                                  return 'Maksimal 15 karakter';
                                }
                                return null;
                              },
                              onFieldSubmitted: (value) {
                                transferSaldo();
                              },
                              controller: beritaController,
                              style: GoogleFonts.poppins(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 19),
                                labelText: "Berita",
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    width: 1,
                                    color: Colors.grey, // Desired focus color
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ).animate().fadeIn(
                                  delay: 800.ms,
                                  curve: Curves.easeIn,
                                  duration: 500.ms,
                                ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 24,
                                    ),
                                  ),
                                  child: const Text(
                                    'Batal',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: transferSaldo,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 24,
                                    ),
                                  ),
                                  child: const Text(
                                    'Kirim',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(
                                delay: 1000.ms,
                                curve: Curves.easeIn,
                                duration: 500.ms,
                              ),
                        ],
                      ),
                    ),
                  ),
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
