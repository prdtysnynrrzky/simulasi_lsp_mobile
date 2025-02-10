import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simulasi_lsp_praditya/widgets/textField.dart';
import '../helpers/currency_format.dart';
import 'receipt_screen.dart';
import '../widgets/appBar.dart';
import '../widgets/button.dart';
import '../providers/balance_provider.dart';
import '../helpers/date_format.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController noRekController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  void transferSaldo() {
    if (!_formKey.currentState!.validate()) return;

    final noRek = noRekController.text.trim();
    final name = nameController.text.trim();
    final nominal = int.tryParse(nominalController.text.trim()) ?? 0;
    final keterangan = keteranganController.text.trim();
    final saldoNotifier = ref.read(balanceProvider.notifier);
    final saldo = ref.read(balanceProvider);

    if (nominal > saldo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo tidak mencukupi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    saldoNotifier.update((state) => state - nominal);

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
          berita: keterangan,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Saldo Anda:',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                CurrencyFormat.toRupiah(
                                    int.parse(saldo.toString())),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          textField(
                            controller: noRekController,
                            hint: 'Masukkan No Rekening Tujuan',
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty
                                ? 'Nomor rekening wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          textField(
                            controller: nameController,
                            hint: 'Masukkan Nama Penerima',
                            validator: (value) => value!.isEmpty
                                ? 'Nama penerima wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          textField(
                            controller: nominalController,
                            hint: 'Masukkan Nominal Transfer',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final nominal = int.tryParse(value ?? '');
                              if (nominal == null || nominal <= 0) {
                                return 'Nominal harus lebih dari 0';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          textField(
                            controller: keteranganController,
                            hint: 'Masukkan Keterangan',
                            validator: (value) {
                              if (value != null && value.length > 15) {
                                return 'Maksimal 15 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: cButton(
                                  text: "Batal",
                                  onPressed: () => Navigator.pop(context),
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: cButton(
                                  text: "Kirim",
                                  onPressed: transferSaldo,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
