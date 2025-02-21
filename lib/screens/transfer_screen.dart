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
    ).then((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final saldo = ref.watch(balanceProvider);

    return Scaffold(
      appBar: customAppBar(
        noRek: '123456789',
        name: 'Rekayasa Perangkat Lunak',
        saldo: CurrencyFormat.toRupiah(saldo),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 19),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Saldo Anda: ${CurrencyFormat.toRupiah(saldo)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: noRekController,
                      label: 'No Rekening Tujuan',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Nomor rekening tujuan wajib diisi'
                          : null,
                    ),
                    _buildTextField(
                      controller: nameController,
                      label: 'Nama Penerima',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Nama penerima wajib diisi'
                          : null,
                    ),
                    _buildTextField(
                      controller: nominalController,
                      label: 'Nominal Transfer',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final nominal = int.tryParse(value ?? '');
                        if (nominal == null || nominal <= 5000) {
                          return 'Nominal transfer harus lebih dari 5000';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: beritaController,
                      label: 'Berita',
                      validator: (value) => value != null && value.length > 15
                          ? 'Maksimal 15 karakter'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Batal',
                                style: TextStyle(color: Colors.white)),
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
                            ),
                            child: const Text('Kirim',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
